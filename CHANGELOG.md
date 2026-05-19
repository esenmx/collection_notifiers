# Changelog

## 2.0.1

- docs: Promoted `flutter_hooks` as the recommended pattern.
- docs: Fixed version migration documentation and cleaned up README.

## 2.0.0

- **Breaking:** `SetNotifier.invert()` now returns `true` when added, `false` when removed.
- fix: `QueueNotifier.add()` not triggering notifications.
- fix: `ListNotifier` notification logic for `replaceRange()` and `setRange()`.
- docs: Enhanced example app and test suite.
- chore: Dart 3 upgrade and lint updates.

## 1.1.0

- Dart 3 upgrade
- Removed dependency constraints
- Updated lints with code reformat

## 1.0.5

- `MapNotifier.addAll` length-based comparison fix
- `MapNotifier`, `ListNotifier` operators improvements
- Support for wider range of dependencies

## 1.0.4

- `SetNotifier.invert(element)` method added

## 1.0.3

- improved docs
- version bumps
- simplified example

## 1.0.2

- `length` based `MapNotifier.addAll/addEntries()` check
- test improvements

## 1.0.1

- Better null value handling in `MapNotifier`
- Diff calculation in `SetNotifier`'s batch operations now `length` based

## 1.0.0+1

- Doc and CI improvements

## 1.0.0

- Initial Release with `Set`, `Map`, `List` and `Queue` support
