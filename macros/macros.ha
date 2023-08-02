// Reads text from stdin, and prints it to stdout, except that any text
// enclosed between delimiters is first evaluated for macros.

use ascii;
use bytes;
use fmt;
use io;
use os;
use regex;
use strings::{fromutf8, toutf8};

// I would have preferred to use a simpler circular linked list approach for this; see <https://todo.sr.ht/~sircmpwn/hare/862>.

type quote = enum u8 {
	OPEN  = 0,
	CLOSE = 1,
};


// XXX: This type is used instead of io::writer because io::writer doesn't
// take io::handle and therefore io::write cannot be an io::writer.
// See hare patch on commit 72429c9.
type _writer = fn(h: io::handle, buf: const []u8) (size | io::error);

type delimiter = struct {
	text: []u8,
	next: quote,
	writer: *_writer,
};

const delims: [_]delimiter = [
	delimiter {
		text = ['`', '`'],
		next = quote::CLOSE,
		writer = &io::write,
	},
	delimiter {
		text = ['\'', '\''],
		next = quote::OPEN,
		writer = &process,
	},
];

// Formats a slice of captures and writes the result to the provided handle.
// Unlike a regex::result, the provided slice does not contain the whole
// expression in the first value. Only the sub-expressions are provided.
type macro_formatter = fn(h: io::handle, captures: []regex::capture) (size | io::error);

type macro = struct {
	desc: str,
	regex: regex::regex,
	formatter: *macro_formatter,
};

def IMG_RE = `img!\([[:space:]]*"(.*)"[[:space:]]*,[[:space:]]*"(.*)"[[:space:]]*\)`;

def UP_RE = `(.*)`;

let macros: [_]macro = [
	//macro {
	//	desc = `img!("src", "alt")`,
	//	format = `<a href="{0}"><img src="{0}" alt="{1}"></a>`,
	//	... // IMG_RE
	//},
	macro {
		desc = `up!(...)`,
		formatter = &up,
		... // UP_RE
	}
];

@init fn initialize_macros() void = {
	macros[0].regex = regex::compile(IMG_RE)!;
};

@fini fn finish_macros() void = {
	for (let i = 0z; i < len(macros); i += 1) {
		regex::finish(&macros[i].regex);
	};
};

// Processes the provided text for the provided macro, writing the processed
// text to the provided handle.
fn process_macro(h: io::handle, buf: const []u8, m: *macro) (size | io::error) = {
	const result = regex::find(&m.regex, fromutf8(buf)!);
	if (len(result) == 0) return 0z;
	defer regex::result_free(result);
	let written = 0z;

	//fmt::printfln("capture start_bytesize: {}, end_bytesize: {}",
	//	result[0].start_bytesize, result[0].end_bytesize)!;
	//for (let j = 0z; j < len(result); j += 1) {
	//	fmt::printfln("capture {}: `{}`", j, result[j].content)!;
	//};

	written += io::write(h, buf[..result[0].start_bytesize])?;

	//written += io::write(h, toutf8("MACRO<"))?;
	//written += io::write(h, toutf8(result[0].content))?;
	//written += io::write(h, ['>'])?;

	written += io::write(h, toutf8("IMG:"))?;
	for (let i = 1z; i < len(result); i += 1) {
		let up = ascii::strupper(result[i].content);
		written += io::write(h, toutf8(up))?;
		free(up);
	};

	written += io::write(h, buf[result[0].end_bytesize..])?;

	return written;
};

// Processes the provided text for macros, writing the processed text to
// the provided handle.
// TODO: nested macros?
fn process(h: io::handle, buf: const []u8) (size | io::error) = {
	let written = 0z;
	for (let i = 0z; i < len(macros); i += 1) {
		written += process_macro(h, buf, &macros[i])?;
	};
	return written;
};

export fn main() void = {
	let buf: []u8 = io::drain(os::stdin)!;
	defer free(buf);

	for (let delim = delims[quote::OPEN], so_far = buf; len(so_far) > 0;
		delim = delims[delim.next]
	) {
		let (before, after) = bytes::cut(so_far, delim.text);

		delim.writer(os::stdout, before)!;

		so_far = after;
	};
};

//// ((.*)``(.*)'')*(.*)
//
//def OPENQUOTE = "``";
//def CLOSEQUOTE = "''";
//
//export fn main() void = {
//	const buf = strings::fromutf8(io::drain(os::stdin)!)!;
//	defer free(buf);
//
//	// TODO: replace any regex special characters in OPENQUOTE or
//	// CLOSEQUOTE with blackslash escaped equivalents.
//	// Can build off of code in globalregularexpressionprint for this.
//	const s = fmt::asprintf(`((.*){}(.*){})*(.*)`, OPENQUOTE, CLOSEQUOTE);
//	//const s = fmt::asprintf(`{}.*{}`, OPENQUOTE, CLOSEQUOTE);
//	defer free(s);
//
//	const re = match (regex::compile(s)) {
//	case let e: regex::error =>
//		fmt::errorfln("Error: bad regex `{}`: {}", s, e)!;
//		os::exit(os::status::FAILURE);
//	case let r: regex::regex =>
//		yield r;
//	};
//	defer regex::finish(&re);
//
//	const results = regex::findall(&re, buf);
//	defer regex::result_freeall(results);
//
//	for (let i = 0z; i < len(results); i += 1) {
//		const result = results[i];
//		for (let j = 0z; j < len(result); j += 1) {
//			fmt::printf("{} ", result[j].content)!;
//		};
//		fmt::println()!;
//	};
//};

