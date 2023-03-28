clean:
	rm -rf build/*.zip

build: $(shell find . -type f)
	@php build.php
