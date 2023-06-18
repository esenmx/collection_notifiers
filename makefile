.PHONY: test publish dry

test:
	flutter test --coverage

dry:
	dart pub publish --dry-run

publish:
	dart pub publish
