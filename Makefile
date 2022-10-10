.POSIX:

# Specifying '/./' in the path strips the 'src/' part of the path when copying
# to $(BUILDDIR). See rsync(1), -R.
SRC = \
	src/./index.html \
	src/./pgp.html \
	src/./public.txt \
	src/./style.css \
	src/./pages/bible.html \
	src/./pages/concentric.html \
	src/./pages/drop.html \
	src/./pages/lsd.html \
	src/./pages/paige.html \
	src/./pages/rosie.html \

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
