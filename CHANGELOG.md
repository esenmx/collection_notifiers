# Changelog

## 2.0.0

### Breaking Changes

- `SetNotifier.invert()` now returns `true` when element is added, `false` when removed (previously returned the result of `add()`/`remove()`)

### Bug Fixes

- Fixed `QueueNotifier.add()` not triggering notifications (was missing override)
- Fixed `ListNotifier.replaceRange()` not notifying when replacing with empty iterable (deletion)
- Fixed `ListNotifier.setRange()` notification logic

### Improvements

- Enhanced documentation, example app, and test suite
- Dart 3 upgrade
- Removed dependency constraints
- Updated lints with code reformat

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
