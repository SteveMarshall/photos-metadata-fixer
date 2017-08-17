all: build lint test
.PHONY: all

build: .build/debug/photos-metadata-fixer lint
.PHONY: build

.build/debug/photos-metadata-fixer: $(shell find Sources -name "*.swift")
	swift build

run: .build/debug/photos-metadata-fixer lint
	.build/debug/photos-metadata-fixer $(FLICKR_USER)
.PHONY: run

HAS_XCPRETTY?=$(shell command -v xcpretty)
ifneq ($(HAS_XCPRETTY),)
XCPRETTY=2>&1 | xcpretty
endif

test: .build/debug/photos-metadata-fixer lint
	swift test $(XCPRETTY)
.PHONY: test

LINTARGS?=--quiet
lint:
	swiftlint $(LINTARGS)
.PHONY: lint

clean:
	rm -rf .build
.PHONY: clean
