# Recipes and pitfalls

## Recipes

### Multi-select with `SetNotifier`

```dart
final selected = useSetNotifier<int>();

ListView(
  children: [
    for (final id in [1, 2, 3])
      CheckboxListTile(
        value: selected.contains(id),
        onChanged: (_) => selected.invert(id),
        title: Text('Item $id'),
      ),
  ],
);
```

`invert(e)` toggles presence — returns `true` if added, `false` if removed.

### Settings with `MapNotifier`

```dart
final settings = useMapNotifier<String, Object>({
  'darkMode': false,
  'fontSize': 14,
});

// In an event handler:
if (settings['darkMode'] case final bool dark) {
  settings['darkMode'] = !dark; // notifies — value changed
}
settings['fontSize'] = 14; // silent — already 14
```

### Reorderable todos with `ListNotifier`

`move` takes the final index that `ReorderableListView.onReorderItem` passes, so
it plugs in directly; `sort` is silent when the list is already sorted.

```dart
class Todo {
  const new(this.title, {this.priority = 0});

  final String title;
  final int priority;
}

class const TodoBoard({super.key}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final todos = useListNotifier<Todo>(const [
      Todo('ship it', priority: 2),
      Todo('write docs', priority: 1),
    ]);
    return Column(
      children: [
        TextButton(
          onPressed: () =>
              todos.sort((a, b) => a.priority.compareTo(b.priority)),
          child: const Text('Sort by priority'),
        ),
        Expanded(
          child: ReorderableListView(
            onReorderItem: todos.move,
            children: [
              for (final todo in todos)
                ListTile(key: ObjectKey(todo), title: Text(todo.title)),
            ],
          ),
        ),
      ],
    );
  }
}
```

### Batch and replace

`batch` runs several synchronous mutations with one notification; `assignAll`
replaces the contents with one notification, silent when equal.

```dart
final cart = useListNotifier<String>();

// In an event handler:
cart.batch(() {
  cart
    ..removeWhere((item) => item.startsWith('tmp'))
    ..add('checkout');
});
cart.assignAll(['apples', 'pears']);
```

## Pitfalls

| ❌ | ✅ |
| --- | --- |
| `notifier = ListNotifier([...])` — reassigning kills listeners | `notifier.assignAll([...])` — mutate in place, one notification |
| Custom element types with default `==` / `hashCode` | `freezed` / `equatable` so equality checks can see real changes |
| `useListNotifier(seed)` with a fresh `seed` per rebuild expecting a reset | pass `keys`, or change the host widget's `key` |
| `StatefulWidget` holding a notifier without disposing | Use the matching hook, or override `dispose` and call `notifier.dispose()` |
| Calling `dispose()` on a hook's notifier | Let the hook dispose it on unmount — a second `dispose()` throws `StateError` |
| `batch(() async { ... })` | Keep the body synchronous; `await` before or after `batch` |
| `MapNotifier(SplayTreeMap(...))` expecting sorted keys | The copy is a `LinkedHashMap` (like `Map.of`); sort when reading, or insert in order |
| `class Todos extends ListNotifier<Todo>` or a fake that `implements` it | The notifiers are `final`: wrap one in your own class, and use a real notifier in tests |

## Migration 1.x → 2.x

**Breaking:** `SetNotifier.invert(e)` return value:

```dart
final selected = SetNotifier<int>();
// v1.x — returned whichever of add()/remove() ran
// v2.x — true if element was added, false if removed
final added = selected.invert(1);
```
