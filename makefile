.PHONY: test publish dry

test:
	flutter test

dry:
	flutter pub publish --dry-run

publish:
	flutter pub publish