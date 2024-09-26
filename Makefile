.PHONY: clean
clean:
	rm -rf build/*.zip

.PHONY: build
build: $(shell find . -type f | grep -v build/)
	@php build.php
