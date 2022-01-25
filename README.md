# Collection Notifiers

`ChangeNotifier`/`ValueListenable` wrappers for collections with optimized notification.

## Why?

Since eliminating some unneeded rebuilds won't make any harm, collection notifiers behaves as syntax sugar most of the
time.

Also, the package aims to be simple with minimum dependency.

## Features

Fully compatible and ease to use with `ValueListeableBuilder` or popular packages like `Riverpod`or `Provider`.

## Implementations

| Collections |   Status    | Implementation | Test Coverage |
|-------------|:-----------:|---------------:|:-------------:|
| Set         |  Completed  |           100% |      65%      |  
| List        | Lacks Tests |           100% |       ?       |
| Map         |   Planned   |             0% |       ?       |
| Stack       |   Planned   |             0% |       ?       |
| Queue       |   Planned   |             0% |       ?       |
| Hash Map    |   Planned   |             0% |       ?       |
| Linked List | Not Planned |              - |       ?       |
| Splay Tree  | Not Planned |              - |       ?       |
| Hash Set    | Not Planned |              - |       ?       |

## Notes

* Keep in the mind, this package is `not concurrency` safe(yet). It's suggested to test your `State`
  for `ConcurrentModificationError`s.
* Operations that require deep collection equality to check differences, triggers the `notifyListener()` all the time
  instead, since the check itself probably much more costly than rebuild itself.
