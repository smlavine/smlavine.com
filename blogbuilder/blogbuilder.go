package main

import (
	"os"
	"strings"

	"github.com/adrg/frontmatter"
	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/renderer/html"
)

var md = goldmark.New(
	goldmark.WithRendererOptions(
		html.WithUnsafe(),
	),
)

type BlogPost struct {
	Title       string `yaml:"title"`
	Date        string `yaml:"date"`
	LastUpdated string `yaml:"last-updated"`
	Text        string // The entire post in HTML, including header and footer.
}

func (post *BlogPost) String() string {
	return post.Text
}

// Reads a blog post written in Markdown, and turns it into a BlogPost. The
// YAML frontmatter is parsed, and the article text is combined with the
// text of the header and footer to produce a full HTML page.
func NewBlogPost(header, footer, filename string) (*BlogPost, error) {
	var post BlogPost

	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}

	article, err := frontmatter.MustParse(f, &post)
	if err != nil {
		return nil, err
	}

	f.Close()

	// TODO: header, footer. html template

	var htmlBuilder strings.Builder
	if err = md.Convert(article, &htmlBuilder); err != nil {
		return nil, err
	}
	post.Text = header + htmlBuilder.String() + footer

	return &post, nil
}

func main() {
}
