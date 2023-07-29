// Reads text from stdin, and prints it to stdout, except that any text
// enclosed between OPENQUOTE and CLOSEQUOTE is first evaluated for macros.

use bytes;
use io;
use fmt;
use os;
use strings::{fromutf8, toutf8};

// TODO: write it here as a string instead? "``" and "''"
let OPENQUOTE:  []u8 = ['`', '`'];   // ``
//let CLOSEQUOTE: []u8 = ['\'', '\'']; // ''
let CLOSEQUOTE: []u8 = ['"', '"']; // ''

// Swaps the delimiter
fn swap(delimiter_ptr_ptr: **[]u8) void = {
	switch (*delimiter_ptr_ptr) {
	case &OPENQUOTE =>
		*delimiter_ptr_ptr = &CLOSEQUOTE;
	case &CLOSEQUOTE =>
		*delimiter_ptr_ptr = &OPENQUOTE;
	case =>
		abort("invalid delimiter");
	};
};

export fn main() void = {
	let buf = io::drain(os::stdin)!;
	defer free(buf);

	for (let delimiter: *[]u8 = &OPENQUOTE, so_far: []u8 = buf;
		len(so_far) > 0;
		swap(&delimiter)
	) {
		// All the text before and after the delimiter
		let (before, after) = bytes::cut(so_far, *delimiter);

		if (delimiter == &OPENQUOTE) {
			// The part before the OPENQUOTE was regular text and
			// therefore should not be processed for macros
			io::write(os::stdout, before)!;
			//fmt::printfln("before: '{}'\n  len(so_far): {}",
			//	fromutf8(before)!, len(so_far))!;
		};

		so_far = after;
	};
};
