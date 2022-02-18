<p align="center">
<a href="https://github.com/esenmx/collection_notifiers/actions"><img src="https://github.com/rrousselGit/river_pod/workflows/Build/badge.svg" alt="Build Status"></a>
<a href="https://codecov.io/gh/esenmx/collection_notifiers"><img src="https://codecov.io/gh/esenmx/collection_notifiers/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/esenmx/collection_notifiers"><img src="https://img.shields.io/github/stars/esenmx/collection_notifiers.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

<p align="center">

Wrapped [collections](https://api.dart.dev/stable/dart-collection/dart-collection-library.html)
with [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
& [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) interface for optimized
rebuilds and better syntax.

## Why?
It's a hassle when working with collections and updating the state. Most of the popular state management packages do not
come with a built-in solution for collections.

**`collection_notifiers` reduces the boilerplate that required update the state while eliminating _unneeded rebuilds_ by 
calculating the difference _very efficiently_.**

It's fully compatible and ease to use with
[ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) or popular
packages
like [Riverpod](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ChangeNotifierProvider-class.html)
/ [Provider](https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html)
via `ChangeNotifierProvider`.

Typical comparison would be:

Riverpod:

```dart
final setProvider = StateProvider((ref) => <E>{});
/// Always triggers [setState]
/// Always creates shallow copies
/// Verbose syntax
onAdd: (value) => ref.read(setProvider.state).update((state) {
  return <E>{...state, value};
});
onRemove: (value) => ref.read(setProvider.state).update((state) {
  return <E>{...state..remove(value);
});
```

Riverpod with `collection_notifiers`:

```dart
final setProvider = ChangeNotifierProvider((ref) => SetNotifier<E>());
/// Does not trigger [setState] if there is no change
/// Never creates shallow copies
/// Terse syntax
onAdd: ref.read(setProvider).add;
onRemove: ref.read(setProvider).remove;
```

Operators are also overridden:
```dart
final listProvider = ChangeNotifierProvider((ref) => ListNotifier([1]));
...
ref.read(listProvider)[0] = 1; // won't trigger setState
```

Similarly:
```dart
final mapProvider = ChangeNotifierProvider((ref) => MapNotifier({'a' : 1}));
...
ref.read(mapProvider)['a'] = 1; // won't trigger setState
```

So what you have is, having significant advantages while paying no real cost.

## Implementations

| Collection |               Status               |   Notifier    |
|------------|:----------------------------------:|:-------------:|
| Set        |           **Completed**            |  SetNotifier  |  
| List       | **Completed**(Not Fully Optimized) | ListNotifier  |
| Map        |           **Completed**            |  MapNotifier  |
| Queue      |           **Completed**            | QueueNotifier |

Ask if there is any specific collection you need, pull requests are also welcome!

## Element Equality

Element equation([== operator](https://api.dart.dev/stable/2.13.4/dart-core/Object/operator_equals.html)) must be
handled by you beforehand. For that case, code generation([freezed](https://pub.dev/packages/freezed), 
[built_value](https://pub.dev/packages/built_value) etc.) or [equatable](https://pub.dev/packages/equatable) are strongly
recommended.

## Notes
* `collection_notifiers` do not handle any `Exception` because it may cause confusing development experience and sneaky
  bugs.
* Methods with overridden logic, always mimics default implementation. Hence, no additional `Exception` is
  also produced.
* Methods that requires collection equalities(like `sort()`, `shuffle()` etc...) always triggers setState.

### Mentions

There is a very similar package [listenable_collections](https://github.com/escamoteur/listenable_collections), but repo
was a little inactive, and probably I'll choose different path over the time. Thanks them, I borrowed some concepts.