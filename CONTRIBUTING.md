# Contributing to collection_notifiers

Thanks for considering a contribution. This is a small, focused Flutter
package that wraps Dart collections with `ChangeNotifier`. Contributions
that keep the scope tight and the public API stable are most welcome.

## Quick start

```bash
git clone https://github.com/esenmx/collection_notifiers.git
cd collection_notifiers
flutter pub get
flutter test
```

## Local checks

Before opening a PR, run the same checks CI runs:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
dart pub publish --dry-run
```

The example app should also build:

```bash
cd example && flutter pub get && flutter analyze
```

## Project conventions

- Modern Dart 3 (sdk `>=3.0.0`). Lints from
  [`very_good_analysis`](https://pub.dev/packages/very_good_analysis).
- Tests use [`package:checks`](https://pub.dev/packages/checks) and
  [`package:mockito`](https://pub.dev/packages/mockito) — see existing
  tests for style. Each mutating override needs a "fires once on real
  change" test **and** a "silent on no-op" test where applicable.
- Source layout: each notifier lives in its own file under `lib/src/`
  and is exposed via `part`/`part of` from `lib/collection_notifiers.dart`.
- "Smart notification" contract: notifying methods must not fire
  `notifyListeners()` when the underlying collection did not change.
  Use one of the canonical patterns:
  - **Equality-guarded single-slot** for `[]=` / setters.
  - **Length-delta diff** for `removeWhere` / `retainWhere` / `removeRange`.
  - **Per-element equality diff** for `fillRange` / `setRange` / `updateAll`.
  - **`containsKey` disambiguation** for `Map` writes where `V` may be `null`.

## Pull requests

- Open PRs against `master`.
- Keep PRs focused — one concern per PR. The CI matrix runs on every PR.
- Add a `CHANGELOG.md` entry under an `Unreleased` section (or a new
  version section for release PRs).
- For breaking changes: bump the major version and call it out at the
  top of the CHANGELOG entry.
- For behavioral additions (existing methods now firing notifications):
  bump the minor version.

## Reporting bugs

Use the bug-report template under
[Issues → New issue](https://github.com/esenmx/collection_notifiers/issues/new/choose).
Include a minimal Dart snippet that reproduces the problem.
