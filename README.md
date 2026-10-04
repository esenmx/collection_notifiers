# collection_notifiers

[![pub](https://img.shields.io/pub/v/collection_notifiers.svg)](https://pub.dev/packages/collection_notifiers) [![pub points](https://img.shields.io/pub/points/collection_notifiers)](https://pub.dev/packages/collection_notifiers/score) [![CI](https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml) [![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Reactive `List` / `Set` / `Map` / `Queue` for Flutter.** Mutate in
place, rebuild on real change only. Ships matching `flutter_hooks`
hooks for one-line widget integration.

## Install

```sh
flutter pub add collection_notifiers
```

## Quick start

```dart
final todos = useListNotifier<String>(['buy milk']);
todos.add('walk dog');   // rebuilds — new element
todos[0] = 'buy milk';   // silent — same value
todos[0] = 'buy eggs';   // rebuilds — value changed
todos.clear();           // rebuilds — was non-empty
todos.clear();           // silent — already empty
```

---

## What it's for

- In-place collection state in a widget: selection toggles, todo
  lists, key/value settings, FIFO/LIFO queues.
- Anywhere `ValueNotifier<List<T>>` would force a `[...state, x]` copy
  per mutation.

## What it isn't

- **Not a state container.** Wrap with `ChangeNotifierProvider`
  (Provider) or expose via a Riverpod notifier when you need DI.
- **Not deep-reactive.** Mutating an element in place
  (`list[0].field = x`) bypasses the equality check — use
  [`freezed`](https://pub.dev/packages/freezed) or
  [`equatable`](https://pub.dev/packages/equatable) for element types,
  or call `notifier.notifyListeners()` after an in-place change.
- **Not for a single value.** Reach for stdlib `ValueNotifier<T>`.

---

## Pick the notifier

|Need|Class|Hook|
|---|---|---|
|Ordered, indexable, reorderable|`ListNotifier`|`useListNotifier`|
|Unique elements, selection toggles|`SetNotifier`|`useSetNotifier`|
|Key → value lookup|`MapNotifier`|`useMapNotifier`|
|FIFO/LIFO head-or-tail mutation|`QueueNotifier`|`useQueueNotifier`|

Each class extends `package:collection`'s `DelegatingX` and mixes in
`ChangeNotifier` — implements `List`/`Set`/`Map` (`dart:core`) or
`Queue` (`dart:collection`), plus `ValueListenable<…>`; the constructor
copies its argument.

---

## Hooks — recommended

The hook owns the lifecycle: creates the notifier on first build,
disposes on unmount, rebuilds the host widget on every real change.
Zero boilerplate.

```dart
class TodoList extends HookWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = useListNotifier<String>(['buy milk']);
    return Column(
      children: [
        FilledButton(
          onPressed: () => todos.add('walk dog'),
          child: const Text('Add'),
        ),
        for (final t in todos) Text(t),
      ],
    );
  }
}
```

`initial` is consumed **once**. Pass `keys` (`useListNotifier(seed, [dep])`)
to recreate the notifier when a dependency changes, or re-key the host
widget.

If the notifier is owned upstream (Riverpod, parent widget), subscribe
without recreating it:

```dart
useListenable(notifier);
```

---

## Without hooks

If `flutter_hooks` is not on the project, fall back to
`ValueListenableBuilder` — the notifier exposes itself as the value:

```dart
final todos = ListNotifier<String>(['buy milk']);

ValueListenableBuilder<List<String>>(
  valueListenable: todos,
  builder: (context, items, _) => Column(
    children: [for (final t in items) Text(t)],
  ),
);
```

Dispose `todos` yourself — `ChangeNotifierProvider` /
`State.dispose` / `ref.onDispose`.

---

## Notification contract

Mutating methods call `notifyListeners()` only when the underlying
collection actually changes.

```dart
final tags = SetNotifier<String>({'flutter', 'dart'});
tags.add('rust');     // notifies — new element
tags.add('rust');     // silent — already present
tags.remove('rust');  // notifies — element removed
tags.remove('rust');  // silent — wasn't there
tags.clear();         // notifies — set drained
tags.clear();         // silent — already empty

final config = MapNotifier<String, int>({'volume': 50});
config['volume'] = 75;  // notifies — value changed
config['volume'] = 75;  // silent — same value
config['bass'] = 30;    // notifies — new key
```

Single-slot writes (`[]=`, `first=`, `last=`, Map `[]=`) always store
the value and notify only when it changed; `batch` and `assignAll`
coalesce several changes into one notification.

### Exceptions

- `ListNotifier.shuffle` on `length > 1` **always** notifies, even
  when the order happens to stay the same.
- `ListNotifier.sort` is silent when the list is already sorted.

---

## Patterns

### Multi-select with `SetNotifier`

```dart
final selected = useSetNotifier<int>();

CheckboxListTile(
  value: selected.contains(id),
  onChanged: (_) => selected.invert(id),
  title: Text('Item $id'),
);
```

`invert(e)` toggles presence — returns `true` if added, `false` if
removed.

### Settings with `MapNotifier`

```dart
final settings = useMapNotifier<String, Object>({
  'darkMode': false,
  'fontSize': 14,
});

settings['darkMode'] = !(settings['darkMode']! as bool);
settings['fontSize'] = 14;   // silent — already 14
```

### Todos with `ListNotifier`

```dart
final todos = useListNotifier<Todo>();

todos.add(Todo(title: 'learn Flutter'));
todos.removeWhere((t) => t.completed);

// reorder
ReorderableListView(
  onReorderItem: todos.move,
  children: [
    for (final t in todos) ListTile(key: ValueKey(t), title: Text(t.title)),
  ],
);

// silent when already sorted
todos.sort((a, b) => a.priority.compareTo(b.priority));
```

### Batch and replace

`batch` runs several mutations with one notification; `assignAll`
replaces the contents with one notification, silent when equal.

```dart
final cart = useListNotifier<String>();

cart.batch(() {
  cart
    ..removeWhere((item) => item.startsWith('tmp'))
    ..add('checkout');
});
cart.assignAll(['apples', 'pears']);
```

### Riverpod

Riverpod 3 moved `ChangeNotifierProvider` to `legacy.dart`.

```dart
import 'package:flutter_riverpod/legacy.dart';

final todosProvider = ChangeNotifierProvider((ref) {
  return ListNotifier<String>(['initial']);
});

class TodoList extends ConsumerWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);
    return Column(children: [for (final t in todos) Text(t)]);
  }
}
```

---

## Pitfalls

|❌|✅|
|---|---|
|`notifier = ListNotifier([...])` — reassigning kills listeners|`notifier.assignAll([...])` — mutate in place, one notification|
|Custom element types with default `==` / `hashCode`|`freezed` / `equatable` so equality checks can see real changes|
|`useListNotifier(seed)` with a fresh `seed` per rebuild expecting a reset|pass `keys`, or change the host widget's `key`|
|`StatefulWidget` holding a notifier without disposing|Use the matching hook, or override `dispose` and call `notifier.dispose()`|

---

## Migration 1.x → 2.x

**Breaking:** `SetNotifier.invert(e)` return value:

```dart
// v1.x — returned whichever of add()/remove() ran
// v2.x — true if element was added, false if removed
selected.invert(1);
```

---

## Agent skill

This package ships an agent skill in `skills/collection-notifiers-usage/`. Install it into your project's agent config with:

```sh
dart run skills@ get --package collection_notifiers --all
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
