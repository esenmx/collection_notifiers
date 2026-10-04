# Changelog

## Unreleased

### Added

- `batch(body)` on every notifier: one notification per batch, silent when no inner call changed anything.
- `assignAll(...)` on every notifier: replaces the contents with one notification, silent when equal.
- `ListNotifier.move(from, to)`: one notification, silent when the contents are unchanged by `==`; use it as `ReorderableListView(onReorderItem: list.move)`.
- Notifiers report their creation to `FlutterMemoryAllocations`, so leak_tracker sees notifiers that are never listened to.

### Changed

- Requires Dart 3.13 / Flutter 3.47 (was Dart 3.10).
- **Behaviour change:** `ListNotifier` `[]=` / `first=` / `last=` and `MapNotifier` `[]=` always store the new value and notify only when `old != new`. An equal-but-distinct value (id-only `==`, `-0.0` over `0.0`) was silently dropped; this reverses the 2.0.2 "no write-back" change.
- Mutating a disposed notifier fails in debug mode before the mutation, including no-op calls.
- `ListNotifier.sort` is silent when the list is already sorted.
- The agent skill moved to `skills/collection-notifiers-usage/` (was `skills/flutter-collection-notifiers/`), so `dart run skills@ get --package collection_notifiers --all` installs it.

### Fixed

- `ListNotifier.insertAll` and `QueueNotifier.addAll` notify for lazy iterables that empty themselves while being added.
- Lazy iterables are read once in `addAll`, `insertAll`, `replaceRange` and `QueueNotifier.addAll`.
- `MapNotifier.update` notifies when `ifAbsent` adds a `null` value.
- `ListNotifier.setRange` rejects a negative `skipCount` with a `RangeError`, like `List`.
- Bulk mutators notify when a callback or iterable throws after a partial change.
- `cast()` views (and `retype()` from `package:collection`) notify when mutated.
- `ListNotifier.addAll` with the notifier itself throws `ConcurrentModificationError` before changing anything, like `List`; it used to append one element and notify first.
- Example: the ValueListenableBuilder panels refresh their buttons, and Map "Add item" always adds a row.
- Docs: `addEntries` is no longer described as length-only, hook `keys` is documented, the Riverpod 3 snippet imports `legacy.dart`, and every snippet compiles.

### Removed

- `homepage` and `documentation` from `pubspec.yaml`.
- The Codecov badge and `codecov.yml`.
- `SECURITY.md` (no private vulnerability-report channel).

## 2.3.1

- fix: enforced transactional boundaries for `ListNotifier.setAll` and `ListNotifier.setRange` by verifying target lengths before executing in-place mutations.
- fix: wrapped `MapNotifier.updateAll` iteration in a `try/finally` block to guarantee `notifyListeners` fires even if the user-provided update callback throws midway.

## 2.3.0

- feat: added optional `keys` dependency array to all hooks (`useListNotifier`, `useMapNotifier`, `useSetNotifier`, `useQueueNotifier`) for keys-based state resets without unmounting the host widget.
- feat: overrode `notifyListeners` as public on all notifiers to support manual UI updates on deep/in-place collection mutations.
- fix: fixed `MapNotifier.addEntries` silent update bug by checking entry-by-entry for key addition or value modification.
- perf: optimized range updates in `ListNotifier.setAll`, `setRange`, and `replaceRange` to compare in-place and only notify on actual content changes.
- docs: README rewritten for pith and consistency with sibling packages (`fluiver`, `rand`). Removed decorative emojis and marketing voice; restructured into per-concern sections with a pitfalls table.

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
