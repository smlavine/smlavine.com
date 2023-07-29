// Reads text from stdin, and prints it to stdout, except that any text
// enclosed between OPENQUOTE and CLOSEQUOTE is first evaluated for macros.

use bytes;
use io;
use os;

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

export fn main() void = {
	let buf: []u8 = io::drain(os::stdin)!;
	defer free(buf);

	for (let delim = DELIMITERS[quote::OPEN], so_far = buf;
		len(so_far) > 0;
		delim = DELIMITERS[delim.next_id]
	) {
		// All the text before and after the delimiter
		let (before, after) = bytes::cut(so_far, delim.text);

		if (delim.id == quote::OPEN) {
			// The part before the quote::OPEN was regular text and
			// therefore should not be processed for macros
			io::write(os::stdout, before)!;
		};

		so_far = after;
	};
};
