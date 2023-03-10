package main

import (
	"fmt"
	"os"
	"sort"
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
	Title   string `yaml:"title"`
	Date    string `yaml:"date"`
	Updated string `yaml:"last-updated"`
	Text    string // The entire blog page, including header and footer.
}

func (post *BlogPost) String() string {
	return post.Text
}

// Reads a blog post written in Markdown, and turns it into a BlogPost. The
// YAML frontmatter is parsed, and the article text is combined with the
// text of the header and footer to produce a full HTML page.
func GenBlogPost(header, footer, filename string) (*BlogPost, error) {
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

type Blog []*BlogPost

// Compiles Markdown blog posts to HTML and combines them with the given
// header and footer templates, and fills in the site index file template and
// the blog index file template.
func BuildBlog(
	indexPath, blogIndexPath, headerPath, footerPath string,
	postPaths ...string,
) error {
	// TODO: headerPath, footerPath => html/template
	header, err := os.ReadFile(headerPath)
	if err != nil {
		return err
	}
	footer, err := os.ReadFile(footerPath)
	if err != nil {
		return err
	}

	blog := make(Blog, 0, len(postPaths))
	for _, postPath := range postPaths {
		newPost, err := GenBlogPost(string(header), string(footer), postPath)
		if err != nil {
			return err
		}
		// Insert newPost into posts such that posts is sorted
		// by descending BlogPost.Date.
		insertionIndex := sort.Search(len(blog), func(i int) bool {
			// Because Dates must be in the form YYYY-MM-DD, we
			// can accurately compare them like so.
			return blog[i].Date <= newPost.Date
		})
		blog = append(blog, nil)
		copy(blog[insertionIndex+1:], blog[insertionIndex:])
		blog[insertionIndex] = newPost
	}

	// TODO: write to site files

	// TODO: write tests to guarantee order of files by date
	for _, post := range blog {
		fmt.Println(post.Date)
	}

	return nil
}

func main() {
	err := BuildBlog("src/index.html",
		"src/blog/index.html",
		"src/blog/header.html",
		"src/blog/footer.html",
		os.Args[1:]...,
	)

	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
	}
}
