.POSIX:

# Specifying '/./' in the path strips the 'src/' part of the path when copying
# to $(BUILDDIR). See rsync(1), -R.
SRC = \
	src/./index.html \
	src/./public.txt \
	src/./style.css \
	src/./blog/bible.html \
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

BUILDDIR = build/

REMOTEPATH = /var/www/smlavine.com

$(BUILDDIR): $(SRC)
	@if [ -d "$(BUILDDIR)" ]; then rm -r $(BUILDDIR); fi
	mkdir $(BUILDDIR)
	@# Later, might include preprocessing/compilation steps
	rsync -R $(SRC) $(BUILDDIR)

build: $(BUILDDIR)

deploy: build
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR) '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR)

.PHONY: build deploy clean
