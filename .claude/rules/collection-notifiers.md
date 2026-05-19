# collection-notifiers — consumer-side rule

Applies when editing Dart code that imports
`package:collection_notifiers/collection_notifiers.dart`.

## Pick the right notifier

|Need|Use|
|---|---|
|Ordered items, indices matter, sort/shuffle/reorder|`ListNotifier<E>`|
|Unique items, selection / multi-select toggles|`SetNotifier<E>`|
|Key → value lookup, settings, key-indexed updates|`MapNotifier<K, V>`|
|FIFO/LIFO, head/tail mutation|`QueueNotifier<E>`|
|A single immutable-ish value|`ValueNotifier<T>` from the SDK — stay with it. `collection_notifiers` is for **collections** that mutate in place.|

## Prefer hooks for consumption

```dart
class TodoList extends HookWidget {
  const TodoList({super.key, required this.notifier});
  final ListNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    final items = useValueListenable(notifier);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => Text(items[i]),
    );
  }
}
```

`ValueListenableBuilder` is fine when hooks aren't already in the
file. Don't mix both in one widget.

## Dispose discipline

If a notifier is owned by a `StatefulWidget`, dispose it in
`State.dispose`. If owned by a Riverpod provider, the provider's own
disposal will handle it (`ChangeNotifierProvider` cleans up on
`dispose`).

```dart
class _Page extends StatefulWidget {
  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  final notifier = ListNotifier<int>();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }
}
```

Never store a notifier as a top-level `final` in a feature file — it
will leak across hot restarts and outlive its scope.

## Element equality matters

The "no-rebuild on no-op" optimisation uses `==` / `hashCode`. For
custom types, use `freezed` or `equatable`. Without proper equality:

```dart
class Item { Item(this.id); final String id; }

final items = ListNotifier<Item>();
items.add(Item('a'));
items[0] = Item('a');  // SAME id, but rebuilds anyway — default `==` is identity.
```

## Don't replace the collection — mutate it

```dart
// ❌ replaces the collection — listeners see the change once but
// downstream Riverpod / Provider readers may not.
notifier = ListNotifier<int>([1, 2, 3]);

// ✅ mutate in place — what the package exists for.
notifier
  ..clear()
  ..addAll([1, 2, 3]);
```

## When to reach for something else

- Need persistence / time-travel / undo → `Drift` + a snapshot table.
- Need cross-isolate sharing → `Isolate` + `SendPort`, not this.
- Need diffing (which items moved) → `package:diffutil_dart` on top of
  the value, or a richer state container.
