.POSIX:

BUILDDIR = public

REMOTEPATH = /var/www/smlavine.com

####

all: \
	$(BUILDDIR) \
	$(BUILDDIR)/blog/style.css \
	$(BUILDDIR)/pages/style.css \
	$(BUILDDIR)/style.css \

# $(BUILDDIR) is seeded with the static files that are simply copied.
# XXX: the build will fail if later build steps need a directory to exist that
# doesn't exist in static
# XXX: $(BUILDDIR) doesn't depend on the CONTENTS of static/ so a `make -B` is
# needed to force a rebuild of the site
$(BUILDDIR): static/
	cp -r static $@

$(BUILDDIR)/style.css: src/main.scss src/style.scss
	sass --no-source-map src/style.scss $@

$(BUILDDIR)/pages/style.css: src/style.scss src/pages/style.scss
	sass --no-source-map src/pages/style.scss $@

$(BUILDDIR)/blog/style.css: src/style.scss src/blog/style.scss
	sass --no-source-map src/blog/style.scss $@

check: accessibility

accessibility: all
	./check-accessibility $(BUILDDIR)

deploy: $(BUILDDIR)
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	@# The slash at the end of $(BUILDDIR) is needed; see 81076bc.
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR)/ '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR)

.PHONY: all accessibility check deploy clean
