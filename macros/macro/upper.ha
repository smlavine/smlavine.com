// A simple macro that converts all lowercase characters within the macro to
// uppercase.
// Useful for debugging and development.

use ascii::{strupper};
use io;
use regex::{compile};
use strings::{toutf8};

def UPPER_RE = `upper!\(([^)]*)\)`;

@init fn append_macro() void = {
	append(macros, macro {
		description = `upper!(...)`,
		regex = compile(UPPER_RE)!,
		formatter = &upper,
	});
};

export fn upper(h: io::handle, args: []str) (size | io::error) = {
	assert(len(args) == 1);
	let s = strupper(args[0]);
	let written = io::write(h, toutf8(s))?;
	free(s);
	return written;
};
