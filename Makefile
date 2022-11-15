.POSIX:

BUILDDIR = build

REMOTEPATH = /var/www/smlavine.com

####

DIRS = $(BUILDDIR) $(BUILDDIR)/blog $(BUILDDIR)/pages $(BUILDDIR)/pages/canvas2019

# Specifying '/./' in the path strips the 'src/' part of the path when copying
# to $(BUILDDIR). See rsync(1), -R.
SRC = \
	src/./index.html \
	src/./public.txt \
	src/./style.css \
	src/./blog/bible.html \
	src/./blog/index.html \
	src/./blog/style.css \
	src/./pages/bible.html \
	src/./pages/paige.html \
	src/./pages/pgp.html \
	src/./pages/rosie.html \
	src/./pages/style.css \
	src/./pages/thing.html \
	src/./pages/canvas2019/concentric.html \
	src/./pages/canvas2019/drop.html \
	src/./pages/canvas2019/lsd.html

all: $(DIRS) copies $(BUILDDIR)/style.css $(BUILDDIR)/pages/style.css $(BUILDDIR)/blog/style.css

$(DIRS):
	if ! [ -d $@ ]; then mkdir $@; fi

copies: copies.mk
	make -f copies.mk

copies.mk: copies.pl copies.txt
	./copies.pl $(BUILDDIR) < copies.txt > copies.mk

$(BUILDDIR)/style.css: src/main.scss src/style.scss
	sass --no-source-map src/style.scss $@

$(BUILDDIR)/pages/style.css: src/main.scss src/pages/style.scss
	sass --no-source-map src/pages/style.scss $@

$(BUILDDIR)/blog/style.css: src/main.scss src/blog/style.scss
	sass --no-source-map src/blog/style.scss $@

deploy: $(BUILDDIR)
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	@# The slash at the end of $(BUILDDIR) is needed; see 81076bc.
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR)/ '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR) copies.mk

.PHONY: copies check deploy clean
