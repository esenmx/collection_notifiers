# Notification semantics and errors

## When listeners are notified

Mutating methods call `notifyListeners()` only when the underlying collection
actually changes.

```dart
final todos = ListNotifier<String>(['buy milk'])
  ..add('walk dog')   // notifies — new element
  ..[0] = 'buy milk'  // silent — same value
  ..[0] = 'buy eggs'  // notifies — value changed
  ..clear()           // notifies — was non-empty
  ..clear();          // silent — already empty

final tags = SetNotifier<String>({'flutter', 'dart'})
  ..add('rust')     // notifies — new element
  ..add('rust')     // silent — already present
  ..remove('rust')  // notifies — element removed
  ..remove('rust')  // silent — wasn't there
  ..clear()         // notifies — set drained
  ..clear();        // silent — already empty

final config = MapNotifier<String, int>({'volume': 50})
  ..['volume'] = 75  // notifies — value changed
  ..['volume'] = 75  // silent — same value
  ..['bass'] = 30;   // notifies — new key
```

Single-slot writes (`[]=`, `first=`, `last=`, Map `[]=`) always store the value
and notify only when it changed; `batch` coalesces notifications and notifies
once if any mutation (or explicit `notifyListeners()`) inside it would have
notified; `assignAll` replaces the contents with one notification when they
differ; `sort` is silent on an already sorted list, and `shuffle` when the order
comes out equal by `==`.

## Misuse throws

In every build mode:

- A disposed notifier throws `StateError` from every mutator, `batch`,
  `notifyListeners`, `addListener`, and a second `dispose()`, before anything
  changes. Reads and `removeListener` still work.
- `dispose()` during a notification throws `StateError` and leaves the notifier
  alive. From a listener, `ChangeNotifier` reports it through
  `FlutterError.onError`, like anything else a listener throws, so the mutation
  that notified returns normally.
- `batch` with an `async` closure or a tear-off typed to return a `Future`
  throws `ArgumentError` without running it — changes made after an `await`
  can't be coalesced.
- A forwarding arrow, `batch(() => load())`, is typed `void`, so `batch` only
  sees the `Future` once `load` has returned: `load` runs, the changes before
  its first `await` notify once, `ArgumentError` follows, and later changes
  notify one by one.
