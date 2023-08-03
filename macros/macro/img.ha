// Converts the provided src and alt-text into an <img> that is surrounded by
// a clickable link to itself (HTML).

use io;
use regex::{compile};
use strings::{toutf8};

def IMG_RE = `img!\([[:space:]]*"(.*)"[[:space:]]*,[[:space:]]*"(.*)"[[:space:]]*\)`;

@init fn append_macro() void = {
	append(macros, macro {
		description = `img!("src", "alt")`,
		regex = compile(IMG_RE)!,
		formatter = &img,
	});
};

export fn img(h: io::handle, args: []str) (size | io::error) = {
	assert(len(args) == 2);

	//let written = 0z;

	//written += io::write(h, toutf8(`<a href="`))?;
	//written += io::write(h, toutf8(args[0]))?;
	//written += io::write(h, toutf8(`"><img src="`))?;
	//written += io::write(h, toutf8(args[0]))?;
	//written += io::write(h, toutf8(`" alt="`))?;
	//written += io::write(h, toutf8(args[1]))?;
	//written += io::write(h, toutf8(`"></a>`))?;

	//return written;

	return io::write(h, toutf8(`<a href="`))?
		+ io::write(h, toutf8(args[0]))?
		+ io::write(h, toutf8(`"><img src="`))?
		+ io::write(h, toutf8(args[0]))?
		+ io::write(h, toutf8(`" alt="`))?
		+ io::write(h, toutf8(args[1]))?
		+ io::write(h, toutf8(`"></a>`))?;
};
