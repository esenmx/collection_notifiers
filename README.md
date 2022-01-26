# collection_notifiers

____

The [collections](https://api.dart.dev/stable/dart-collection/dart-collection-library.html) wrapped
with [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
& [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) for optimized notification
and simple syntax.

## Why?

____
It's a hassle when working with collections and updating the state. Most of the popular state management packages are
not comes with a built-in solution.

`collection_notifiers` reducing the boilerplate and preventing the unneeded rebuilds most of the time. It's minimal with
single dependency, [collection](https://pub.dev/packages/collection).

## Features

____

Fully compatible and ease to use
with [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) or popular
packages
like [riverpod](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ChangeNotifierProvider-class.html)
/ [provider](https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProvider-class.html) (`ChangeNotifierProvider`)
.

## Implementations

| Collections |   Status    | Implementation | Test Coverage |
|-------------|:-----------:|---------------:|:-------------:|
| Set         |  Completed  |           100% |      96%      |  
| List        | Lacks Tests |           100% |       ?       |
| Map         |   Planned   |             0% |       ?       |
| Queue       |   Planned   |             0% |       ?       |
| Hash Map    |   Planned   |             0% |       ?       |
| Linked List | Not Planned |              - |       ?       |
| Splay Tree  | Not Planned |              - |       ?       |
| Hash Set    | Not Planned |              - |       ?       |

### Element Equality

____

## Notes

____

* Keep in the mind, this package is `not concurrency safe`, yet... It's suggested to test your `State`
  for `ConcurrentModificationError`s.
* Operations that require deep collection equality to check differences, triggers `notifyListener()` all time instead,
  because check itself probably more costly than rebuild.

### Mentions

___

There is a very similar package [listenable_collections](https://github.com/escamoteur/listenable_collections),
but repo was a little inactive, and probably I'll choose different direction over time. So, I created a new repository.
Thanks them, I borrowed some concepts.
