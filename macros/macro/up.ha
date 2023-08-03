// A simple macro that converts all lowercase characters within the macro to
// uppercase.
// Not really that practical, but useful for debugging and development.

use ascii::{strupper};
use io;
use regex::{compile};
use strings::{toutf8};

def UP_RE = `up!\(([^)]*)\)`;

@init fn append_macro() void = {
	append(macros, macro {
		description = `up!(...)`,
		regex = compile(UP_RE)!,
		formatter = &up,
	});
};

export fn up(h: io::handle, args: []str) (size | io::error) = {
	assert(len(args) == 1);
	let s = strupper(args[0]);
	let written = io::write(h, toutf8(s))?;
	free(s);
	return written;
};
