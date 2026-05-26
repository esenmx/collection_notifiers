# Changelog

## Unreleased

- docs: README rewritten for pith and consistency with sibling
  packages (`fluiver`, `rand`). Removed decorative emojis and
  marketing voice; restructured into per-concern sections with a
  pitfalls table.

## 2.2.0

- feat: ship dedicated `flutter_hooks` hooks for every notifier —
  `useListNotifier`, `useSetNotifier`, `useMapNotifier`,
  `useQueueNotifier`. Each owns the lifecycle: creates on first build,
  disposes on unmount, rebuilds the host widget on every mutation.
- feat: `flutter_hooks` is now a runtime dependency.
- docs: agent skill at `skills/flutter-collection-notifiers/SKILL.md`
  replaces the old `rules/collection_notifiers.md`.
- docs: stronger "hooks recommended" framing in the library dartdoc;
  method-level notes on `ListNotifier.sort`/`shuffle` (always notify
  when `length > 1`) and `MapNotifier.addEntries` (length-only check).
- docs: shallow-copy semantics called out on every notifier constructor.
- example: each tab now shows a hooks panel (`useXNotifier`,
  self-contained) alongside the externally-owned `ValueListenableBuilder`
  panel.
- test: widget tests for all four hooks covering single-instance reuse,
  dispose-on-unmount, rebuild-on-mutation, and one-time `initial`
  semantics.

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
