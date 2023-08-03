// Reads text from stdin, and prints it to stdout, except that any text
// enclosed between delimiters is first evaluated for macros.

use bytes;
use io;
use os;


use macro;

// XXX: This type is used instead of io::writer because io::writer doesn't
// take io::handle and therefore io::write cannot be an io::writer.
// See hare patch on commit 72429c9.
type _writer = fn(h: io::handle, buf: const []u8) (size | io::error);

// Delimiters around macro sections.
type delimiter = struct {
	text: []u8,
	next: size,  // Index of corresponding delimiter in delims array
	writer: *_writer,
};

// I would have preferred to use a simpler circular linked list approach
// instead of an indexed array; see <https://todo.sr.ht/~sircmpwn/hare/862>.
const delims: [_]delimiter = [
	delimiter {
		text = ['`', '`'],
		next = 1,
		writer = &io::write,
	},
	delimiter {
		text = ['\'', '\''],
		next = 0,
		writer = &macro::process,
	},
];

//def IMG_RE = `img!\([[:space:]]*"(.*)"[[:space:]]*,[[:space:]]*"(.*)"[[:space:]]*\)`;

export fn main() void = {
	let in: []u8 = io::drain(os::stdin)!;
	defer free(in);

	for (let d = delims[0], buf = in; len(buf) > 0; d = delims[d.next]) {
		let (before, after) = bytes::cut(buf, d.text);
		d.writer(os::stdout, before)!;
		buf = after;
	};
};
