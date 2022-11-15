.POSIX:

BUILDDIR = site

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

all: $(DIRS) copies

copies: copies.mk
	make -f copies.mk

copies.mk: build/copies.pl build/copies.txt
	build/copies.pl $(BUILDDIR) < build/copies.txt > copies.mk

$(DIRS):
	if ! [ -d $@ ]; then mkdir $@; fi

deploy: $(BUILDDIR)
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR) '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR) copies.mk

.PHONY: copies check deploy clean
