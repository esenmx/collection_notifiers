# collection_notifiers

The [collections](https://api.dart.dev/stable/dart-collection/dart-collection-library.html) wrapped
with [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
& [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) for optimized notification
and simpler/efficient syntax.

## Why?

It's a hassle when working with collections and updating the state. Most of the popular state management packages do not
come with a built-in solution.

`collection_notifiers` eliminating the boilerplate and unneeded rebuilds by calculating the difference very
**efficiently**. It's minimal with a single dependency: [collection](https://pub.dev/packages/collection).

So what will you get is, having significant advantages while paying no cost.

## Features

Fully compatible and ease to use
with [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) or popular
packages
like [Riverpod](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ChangeNotifierProvider-class.html)
/ [Provider](https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html)
via `ChangeNotifierProvider`.

## Implementations

| Collection Name |    Status     |   Notifier Name   |
|-----------------|:-------------:|:-----------------:|
| Set             | **Completed** |    SetNotifier    |  
| List            | Needs Tweaks  |   ListNotifier    |
| Map             | Lacking Tests |    MapNotifier    |
| Queue           |    Planned    |   QueueNotifier   |
| SplayTree       |    Triage     | SplayTreeNotifier |
| LinkedList      |    Triage     |         -         |
| HashMap         |  Not Planned  |         -         |
| HashSet         |  Not Planned  |                   |

### Element Equality

Element equation([== operator](https://api.dart.dev/stable/2.13.4/dart-core/Object/operator_equals.html)) must be
handled by you beforehand. For that case, code generation([freezed](https://pub.dev/packages/freezed)
, [built_value](https://pub.dev/packages/built_value) etc.) or [equatable](https://pub.dev/packages/equatable) strongly
recommended.

## Notes

* `collection_notifiers` do not handle any `Exception` because it may cause misleading development experience and sneaky
  bugs.
* Methods with overridden logic, always mimics default implementation effectively. Hence, no extra `Exception` is also
  produced.

### Mentions

There is a very similar package [listenable_collections](https://github.com/escamoteur/listenable_collections), but repo
was a little inactive, and probably I'll choose different direction over time. So, I created a new repository. Thanks
them, I borrowed some concepts.
