# Contributing

1. `flutter pub get`
2. Run the checks CI runs:

   ```sh
   git ls-files -z -- '*.dart' |
     xargs -0 dart format --output=none --set-exit-if-changed
   flutter analyze --fatal-infos --fatal-warnings
   flutter test
   npx --yes markdownlint-cli2@0.23.3
   dart run tool/check_snippets.dart \
     --import package:collection_notifiers/collection_notifiers.dart \
     --import package:flutter/material.dart \
     --import package:flutter_hooks/flutter_hooks.dart \
     --dep flutter_riverpod
   flutter pub publish --dry-run
   cd example
   flutter pub get
   flutter analyze --fatal-infos --fatal-warnings
   flutter test
   ```

   CI also runs `pana`, analyze and test after `flutter pub downgrade`, and the
   tests on the Flutter 3.47.0 floor and the beta channel.

3. Add a line under `## Unreleased` in `CHANGELOG.md` for every user-visible
   change.

Releases are published manually by the maintainer.
