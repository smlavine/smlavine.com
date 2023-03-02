.POSIX:

BUILDDIR = site

REMOTEPATH = /var/www/smlavine.com

####

DIRS = $(BUILDDIR) $(BUILDDIR)/blog $(BUILDDIR)/pages $(BUILDDIR)/pages/canvas2019

POSTS = src/blog/bible.md src/blog/syncthing.md

all: \
	$(DIRS) \
	copies \
	$(BUILDDIR)/blog/style.css \
	$(BUILDDIR)/pages/style.css \
	$(BUILDDIR)/style.css \
	blog \

$(DIRS):
	if ! [ -d $@ ]; then mkdir $@; fi

copies: copies.mk
	make -f copies.mk

copies.mk: copies.pl copies.txt $(DIRS)
	./copies.pl $(BUILDDIR) < copies.txt > copies.mk

$(BUILDDIR)/style.css: src/main.scss src/style.scss
	sass --no-source-map src/style.scss $@

$(BUILDDIR)/pages/style.css: src/main.scss src/pages/style.scss
	sass --no-source-map src/pages/style.scss $@

$(BUILDDIR)/blog/style.css: src/main.scss src/blog/style.scss
	sass --no-source-map src/blog/style.scss $@

check: accessibility go-test

accessibility: all
	./check-accessibility $(BUILDDIR)

deploy: $(BUILDDIR)
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	@# The slash at the end of $(BUILDDIR) is needed; see 81076bc.
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR)/ '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR) copies.mk .bin

.PHONY: copies go blog go-test accessibility check deploy clean
