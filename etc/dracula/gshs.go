package main

import (
	"os"
	"github.com/alecthomas/chroma/v2/formatters/html"
	"github.com/alecthomas/chroma/v2/styles"
)

func main() {
	formatter := html.New(html.WithAllClasses(true))
	formatter.WriteCSS(os.Stdout, styles.Get("dracula"))
}
