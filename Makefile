.POSIX:

BUILDDIR = build

REMOTEPATH = /var/www/smlavine.com

####

DIRS = $(BUILDDIR) $(BUILDDIR)/blog $(BUILDDIR)/pages $(BUILDDIR)/pages/canvas2019

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

check: $(BUILDDIR)
	./check-accessibility $(BUILDDIR)

deploy: $(BUILDDIR)
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	@# The slash at the end of $(BUILDDIR) is needed; see 81076bc.
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR)/ '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR) copies.mk

.PHONY: copies check deploy clean
