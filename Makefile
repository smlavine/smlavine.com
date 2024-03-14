.POSIX:

OUTDIR = public

REMOTEPATH = /var/www/smlavine.com

####

all: \
	kiln \
	$(OUTDIR)/style.css \
	$(OUTDIR)/pages/style.css \
	$(OUTDIR)/blog/style.css

# Kiln builds and templates site content and copies static content into the
# proper place.
kiln:
	kiln build

$(OUTDIR)/style.css: style/main.scss style/style.scss style/blog-posts.scss
	sass --no-source-map style/style.scss $@

$(OUTDIR)/pages/style.css: style/style.scss style/pages/style.scss
	sass --no-source-map style/pages/style.scss $@

$(OUTDIR)/blog/style.css: style/style.scss style/blog/style.scss
	sass --no-source-map style/blog/style.scss $@

check: accessibility

accessibility: all
	./check-accessibility $(OUTDIR)

deploy: $(OUTDIR)
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	@# The slash at the end of $(OUTDIR) is needed; see 81076bc.
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(OUTDIR)/ '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(OUTDIR)

.PHONY: all accessibility check deploy clean kiln
