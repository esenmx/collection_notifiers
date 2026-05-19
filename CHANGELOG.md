# Changelog

## 2.1.0

- feat: `ListNotifier` now notifies listeners for the `length=`, `first=`,
  and `last=` setters. Previously these inherited from `DelegatingList`
  and mutated silently. If you depend on silence here, audit call sites.

## 2.0.2

- fix: `ListNotifier.fillRange` now runs `RangeError.checkValidRange` before the
  `fillValue` cast and short-circuits on empty ranges, so an empty no-op call
  no longer crashes when `fillValue` is omitted.
- fix: `MapNotifier.addAll` no longer skips notification when a new key is
  added with a `null` value (false-negative on `super[key] != value` for
  absent keys with null defaults).
- fix: `ListNotifier.operator []=` and `MapNotifier.operator []=` no longer
  write the same value back when the value is unchanged.
- fix: `MapNotifier.putIfAbsent` returns the value from the underlying
  `putIfAbsent` call instead of re-reading via `super[key]!`.
- test: expanded coverage with dispose semantics, `removeListener`,
  re-entrant listener mutation, null-element handling, and
  `ValueListenableBuilder` rebuild integration.
- chore: added `issue_tracker` to `pubspec.yaml`.

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
