package main

import (
	"fmt"
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
	Title   string `yaml:"title"`
	Date    string `yaml:"date"`
	Updated string `yaml:"last-updated"`
	Header  string
	Article string
	Footer  string
}

func (post *BlogPost) String() string {
	return post.Header + post.Article + post.Footer
}

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
	post.Header = header
	post.Footer = footer

	var htmlBuilder strings.Builder
	if err = md.Convert(article, &htmlBuilder); err != nil {
		return nil, err
	}
	post.Article = htmlBuilder.String()

	return &post, nil
}

func main() {
	post, err := GenBlogPost("<title>Why bears suck</title>", "<hr><hr><hr>", "src/blog/bible.md")
	if err != nil {
		panic(err)
	}

	fmt.Print(post)
}

//---
//title: KJV Bible pictures
//date: 2022-02-23
//last-updated: 2022-02-23
//---
//
//Here are some pictures of a little King James Bible I got at a thrift
//store a few years ago for a dollar.
//
//
