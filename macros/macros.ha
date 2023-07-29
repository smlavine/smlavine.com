// Reads text from stdin, and prints it to stdout, except that any text
// enclosed between OPENQUOTE and CLOSEQUOTE is first evaluated for macros.

use bytes;
use io;
use os;

// An error was encountered when processing a macro.
type error = !void;

// I would have preferred to use a simpler circular linked list approach for
// this; see <https://todo.sr.ht/~sircmpwn/hare/862>.

type quote = enum u8 {
	OPEN  = 0,
	CLOSE = 1,
};

type delimiter = struct {
	text: []u8,
	id: quote,
	next_id: quote,
};

const DELIMITERS: [_]delimiter = [
	delimiter {
		text = ['`', '`'],
		id = quote::OPEN,
		next_id = quote::CLOSE,
	},
	delimiter {
		//text = ['\'', '\''],
		text = ['"', '"'],
		id = quote::CLOSE,
		next_id = quote::OPEN,
	},
];

fn process(text: []u8) (error | void) = {
	return void;
};

export fn main() void = {
	let buf: []u8 = io::drain(os::stdin)!;
	defer free(buf);

	for (let delim = DELIMITERS[quote::OPEN], so_far = buf;
		len(so_far) > 0;
		delim = DELIMITERS[delim.next_id]
	) {
		// All the text before and after the delimiter
		let (before, after) = bytes::cut(so_far, delim.text);

		switch (delim.id) {
		case quote::OPEN =>
			// before the open quote is regular text; do not
			// process for macros
			io::write(os::stdout, before)!;
		case quote::CLOSE =>
			process(before)!;
		};

		so_far = after;
	};
};
