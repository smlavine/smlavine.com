.POSIX:

SRC = src/

BUILDDIR = build/

REMOTEPATH = /var/www/smlavine.com

$(BUILDDIR): $(SRC)
	@if [ -d "$(BUILDDIR)" ]; then rm -r $(BUILDDIR); fi
	mkdir $(BUILDDIR)
	@# Later, might include preprocessing/compilation steps
	cp -r src/* $(BUILDDIR)

build: $(BUILDDIR)

deploy: build
	@if [ ! "$(deploy)" ]; then echo 'Error: deploy must be set.'; exit 1; fi
	rsync --rsh='ssh -o StrictHostKeyChecking=no' -r $(BUILDDIR) '$(deploy):$(REMOTEPATH)'

clean:
	rm -rf $(BUILDDIR)

.PHONY: build deploy clean
