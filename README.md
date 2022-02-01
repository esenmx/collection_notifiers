# collection_notifiers

___

The [collections](https://api.dart.dev/stable/dart-collection/dart-collection-library.html) wrapped
with [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
& [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) for optimized notification
and simple syntax.

## Why?

___
It's a hassle when working with collections and updating the state. Most of the popular state management packages do not
come with a built-in solution.

`collection_notifiers` reducing the boilerplate and preventing the unneeded rebuilds most of the time. It's minimal with
a single dependency: [collection](https://pub.dev/packages/collection).

## Features

___

Fully compatible and ease to use
with [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) or popular
packages
like [Riverpod](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ChangeNotifierProvider-class.html)
/ [Provider](https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html) (`ChangeNotifierProvider`)
.

## Implementations

| Collections |    Status     | Implementation | Test Coverage |
|-------------|:-------------:|---------------:|:-------------:|
| Set         |   Completed   |           100% |      96%      |  
| List        |   Completed   |           100% |      97%      |
| Map         | Lacking Tests |           100% |      0%       |
| Queue       |    Planned    |             0% |       ?       |
| Hash Map    |    Planned    |             0% |       ?       |
| Linked List |  Not Planned  |              - |       ?       |
| Splay Tree  |  Not Planned  |              - |       ?       |
| Hash Set    |  Not Planned  |              - |       ?       |

### Element Equality

___

## Notes

___

* Keep in the mind, this package is `not concurrency safe`, yet... It's suggested to test your `State`
  for `ConcurrentModificationError`s.
* Operations that require deep collection equality to check differences, triggers `notifyListener()` all time instead,
  because check itself probably more costly than rebuild. Lately, this will be changed and calculation of differences
  will be handled effectively.

### Mentions

___

There is a very similar package [listenable_collections](https://github.com/escamoteur/listenable_collections), but repo
was a little inactive, and probably I'll choose different direction over time. So, I created a new repository. Thanks
them, I borrowed some concepts.
