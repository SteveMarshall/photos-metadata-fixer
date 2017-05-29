build: .build/debug/photos-metadata-fixer lint
.PHONY: build

.build/debug/photos-metadata-fixer: Sources/*
	swift build

run: build
	.build/debug/photos-metadata-fixer
.PHONY: run

lint: Sources/*
	swiftlint
.PHONY: lint

clean:
	rm -rf .build Packages
.PHONY: clean
