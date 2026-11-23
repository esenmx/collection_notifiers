---
name: collection-notifiers-usage
description: 'Wire reactive List/Set/Map/Queue state in Flutter via `package:collection_notifiers` — selection toggles, multi-select chips, mutable todo lists, key/value settings, in-memory caches, job queues. Use for any in-place collection state driving UI; not for a single immutable value (`ValueNotifier`).'
license: MIT
metadata: {version: "1"}
---

# collection-notifiers-usage

|Need|Hook|Ops|
|-|-|-|
|Ordered, indexable, reorderable|`useListNotifier<E>([initial])`|`add`, `assignAll`, `move`, `removeAt`|
|Unique elements, selection toggles|`useSetNotifier<E>([initial])`|`invert(x)`, `add`, `remove`|
|Key -> value lookup|`useMapNotifier<K, V>([initial])`|`m[k] = v`, `remove(k)`|
|FIFO/LIFO head-or-tail mutation|`useQueueNotifier<E>([initial])`|`addLast`, `removeFirst`|

Each hook creates the notifier, disposes on unmount, and rebuilds the host on real changes.

```dart
class const FilterChips({required final List<String> tags, super.key})
    extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final selected = useSetNotifier<String>();
    return Wrap(
      children: [
        for (final tag in tags)
          FilterChip(
            label: Text(tag),
            selected: selected.contains(tag),
            onSelected: (_) => selected.invert(tag),
          ),
      ],
    );
  }
}
```

## Hard rules

- **Mutate, never reassign**: `notifier.assignAll([...])` (1 notification), never `notifier = ListNotifier(...)`. Reorder with `ReorderableListView(onReorderItem: list.move)`.
- **Coalesce with `batch(() { ... })`**: body must be sync; an `async` closure throws `ArgumentError` up front. A `void` arrow forwarding `batch(() => load())` runs until first `await` (notifies once), then throws `ArgumentError`, and later writes notify individually.
- **Disposal**: mutators, `batch`, `notifyListeners`, `addListener`, and double `dispose()` throw `StateError` in every build mode. Hooks auto-dispose. `dispose()` during notification throws `StateError` leaving notifier alive (from a listener it reaches `FlutterError.onError`).
- **`initial` consumed once**: pass hook `keys` (`useListNotifier(initial, [dep])`) or change widget `key` to reset.
- **Backing copy**: copied like `Map.of`/`Set.of` (`LinkedHashMap`/`LinkedHashSet`, insertion order, `==` equality — `SplayTreeMap` order / identity sets are not preserved).
- **Compose, don't subclass**: notifiers are `final` (hold in a field; use real notifiers in tests).
- **Equality**: `==`/`hashCode` gate notifications (use `freezed`/`equatable` on custom elements); call public `notifyListeners()` after in-place element mutation.
- **Skip for**: single immutable value (`ValueNotifier`), persisted/undoable state (`drift`), cross-isolate state (`Isolate`+`SendPort`).
