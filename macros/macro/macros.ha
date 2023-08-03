use fmt;
use io;
use regex;
use strings::{dup, fromutf8, toutf8};
use strio;

// Formats a slice of strings and writes the result to the provided handle.
export type formatter = fn(h: io::handle, args: []str) (size | io::error);

// The information necessary to describe, identify, and expand a macro.
export type macro = struct {
	description: const str,
	regex: regex::regex,
	formatter: *formatter,
};

// the contents of macros is @init'd in the various macro source files.

// A slice containing all of the macros that have been defined.
export let macros: []macro = [];

@fini fn finish_macros() void = {
	for (let i = 0z; i < len(macros); i += 1) {
		regex::finish(&macros[i].regex);
	};
	free(macros);
};

// Processes the provided text for macros, writing the processed text to the
// provided handle.
export fn process(h: io::handle, buf: const []u8) (size | io::error) = {
	let written = 0z;

	for (let i = 0z; i < len(macros)) {
		const result = regex::find(&macros[i].regex, fromutf8(buf)!);
		//fmt::println("i =", i, "len(result) =", len(result))!;

		if (len(result) == 0) {
			i += 1;
			continue;
		};

		defer regex::result_free(result);

		// From the beginning of the buffer to the start of the regex
		// match is regular text that should not be processed.
		written += io::write(h, buf[..result[0].start_bytesize])?;


		let macro_args: []str = alloc([], len(result) - 1);
		defer {
			for (let i = 0z; i < len(macro_args); i += 1) {
				free(macro_args[i]);
			};
			free(macro_args);
		};

		// The macro captures might have other macros that have to be
		// evaluated first. Process them for macros before putting them
		// in macro_args.
		for (let i = 1z; i < len(result); i += 1) {
			let a = strio::dynamic();
			defer io::close(&a): void;
			process(&a, toutf8(result[i].content))?;
			static append(macro_args, dup(strio::string(&a)));
		};

		assert(len(macro_args) == len(result) - 1,
			"Some arguments got lost on the cutting room floor");

		// Now we can finally process the macro we are currently
		// working with.
		written += macros[i].formatter(h, macro_args)?;

		// Beyond the regex match might be regular text, but there
		// might also be more regexes to match. Advance the buffer
		// slice and start over the macro loop again.
		buf = buf[result[0].end_bytesize..];
		i = 0;
	};

	// Anything remaining in buf was after the last macro (if there were
	// any at all).
	written += io::write(h, buf)?;

	return written;
};
