# collection_notifiers

<a href="https://pub.dev/packages/collection_notifiers"><img src="https://img.shields.io/pub/v/collection_notifiers.svg" alt="Build Status"></a>
<a href="https://github.com/esenmx/collection_notifiers/actions"><img src="https://github.com/esenmx/collection_notifiers/workflows/Build/badge.svg" alt="Build Status"></a>
<a href="https://codecov.io/gh/esenmx/collection_notifiers"><img src="https://codecov.io/gh/esenmx/collection_notifiers/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/esenmx/collection_notifiers"><img src="https://img.shields.io/github/stars/esenmx/collection_notifiers.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

Wrapped [collections][collections] with [ChangeNotifier][ChangeNotifier] & [ValueListenable][ValueListenable]
interface for optimized rebuilds and better syntax.

## Features

- Huge performance benefits for medium/large collections

- Best possible syntax, minimum amount of code

- Fully compatible with [ValueListenableBuilder][ValueListenableBuilder] and [Riverpod][Riverpod] / [Provider][Provider]

- Dead simple to use

### Riverpod/Provider without `collection_notifiers`

- Always `triggers setState`
- Always `creates copies`
- `Verbose` syntax

```dart
final setProvider = StateProvider((ref) => <E>{});
```

```dart
onAdd: (value) => ref.read(setProvider.state).update((state) {
  return <E>{...state, value}; // a new copy created
});
onRemove: (value) => ref.read(setProvider.state).update((state) {
  return <E>{...state..remove(value)}; // a new copy created
});
```

### Riverpod/Provider with `collection_notifiers`

- Triggers `setState only when needed`
- Creates `zero copy`
- `Terse` syntax

```dart
final setProvider = ChangeNotifierProvider((ref) => SetNotifier<E>());
```

```dart
onAdd: ref.read(setProvider).add; // does not create copy
onRemove: ref.read(setProvider).remove; // does not create copy
```

Operators are also overridden, `List`:

```dart
final listProvider = ChangeNotifierProvider((ref) => ListNotifier([0]));
ref.read(listProvider)[0] = 1; // will trigger setState
ref.read(listProvider)[0] = 1; // won't trigger setState
```

Similarly, the `Map`:

```dart
final mapProvider = ChangeNotifierProvider((ref) => MapNotifier());
ref.read(mapProvider)['a'] = 1; // will trigger setState
ref.read(mapProvider)['a'] = 1; // won't trigger setState
```

## Implementations

| Collection |               Status               |   Notifier    |
|------------|:----------------------------------:|:-------------:|
| Set        |           **Completed**            |  SetNotifier  |  
| List       |     **Completed**(_see notes_)     | ListNotifier  |
| Map        |           **Completed**            |  MapNotifier  |
| Queue      |           **Completed**            | QueueNotifier |

_Open an issue if there is any specific collection/method you need._

## Element Equality

Element equation([== operator](https://api.dart.dev/stable/2.13.4/dart-core/Object/operator_equals.html)) must be
handled by you beforehand. For that case, code generation([freezed][freezed], [built_value][built_value] etc.) or
[equatable][equatable] are highly recommended.

## Notes

- `collection_notifiers` do not handle any `Exception` because it may cause confusing development experience and sneaky
  bugs.

- Methods with overridden logic, always mimics default implementation. Hence, no additional `Exception` is
  also produced.
  
- Methods that requires collection equalities(like `sort()`, `shuffle()` etc...) always trigger setState.

[//]: # (Links)

[collections]: https://api.dart.dev/stable/dart-collection/dart-collection-library.html
[ChangeNotifier]: https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html
[ValueListenable]: https://api.flutter.dev/flutter/foundation/ValueListenable-class.html
[ValueListenableBuilder]: https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html
[Riverpod]: https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ChangeNotifierProvider-class.html
[Provider]: https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html
[freezed]: https://pub.dev/packages/freezed
[built_value]: https://pub.dev/packages/built_value
[equatable]: https://pub.dev/packages/equatable
