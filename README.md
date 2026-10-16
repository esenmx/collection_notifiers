# collection_notifiers

[![pub][pub-badge]][pub] [![pub points][points-badge]][points]
[![CI][ci-badge]][ci] [![license][license-badge]](LICENSE)

`List`, `Set`, `Map` and `Queue` that notify their listeners when their contents
change. Edit the collection in place — `add`, `remove`, `[]=` — and your widgets
rebuild only when something really changed.

## Why

Flutter's `ValueNotifier` only notices when you replace its value. Call
`todos.value.add('walk dog')` on a `ValueNotifier<List<String>>` and the list
changes, but no listener hears about it. So every change becomes a copy,
`todos.value = [...todos.value, 'walk dog']`, and because each copy is a new
list, it notifies even when nothing changed.

With `collection_notifiers`:

- **You mutate in place.** The notifier _is_ the collection: no copy per change.
- **Listeners hear only real changes.** Adding an element a set already holds,
  writing the value a slot already holds, or clearing an empty list notifies
  nobody (one exception: [`shuffle`](#exceptions)).
- **A hook per type does the wiring.** `useListNotifier`, `useSetNotifier`,
  `useMapNotifier` and `useQueueNotifier` create the notifier, rebuild your
  widget when it changes, and dispose it on unmount: no `StatefulWidget`, no
  `dispose`, no builder widget.

## Quick start

```sh
flutter pub add collection_notifiers flutter_hooks
```

```dart
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class const TodoList({super.key}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final todos = useListNotifier<String>(['buy milk']);
    return Column(
      children: [
        FilledButton(
          onPressed: () => todos.add('walk dog'),
          child: const Text('Add'),
        ),
        for (final todo in todos) Text(todo),
      ],
    );
  }
}
```

Tapping **Add** appends to the list in place and rebuilds `TodoList`. The hook
creates the notifier on the first build and disposes it when the widget leaves
the tree. `flutter_hooks` provides `HookWidget`; to skip hooks, see
[Without hooks](#without-hooks).

---

## Is it for you?

Use it for:

- In-place collection state in a widget: selection toggles, todo lists,
  key/value settings, FIFO/LIFO queues.
- Anywhere `ValueNotifier<List<T>>` would force a `[...state, x]` copy per
  mutation.

It isn't:

- **A state container.** Provide a notifier with `ChangeNotifierProvider`
  (Provider, or Riverpod's `legacy.dart`, see [Riverpod](#riverpod)) when you
  need dependency injection.
- **Deep-reactive.** Mutating an element in place (`list[0].field = x`) bypasses
  the equality check — use [`freezed`](https://pub.dev/packages/freezed) or
  [`equatable`](https://pub.dev/packages/equatable) for element types, or call
  `notifier.notifyListeners()` after an in-place change.
- **For a single value.** Reach for stdlib `ValueNotifier<T>`.

## Pick the notifier

| Need | Class | Hook |
| --- | --- | --- |
| Ordered, indexable, reorderable | `ListNotifier` | `useListNotifier` |
| Unique elements, selection toggles | `SetNotifier` | `useSetNotifier` |
| Key → value lookup | `MapNotifier` | `useMapNotifier` |
| FIFO/LIFO head-or-tail mutation | `QueueNotifier` | `useQueueNotifier` |

Each class extends `package:collection`'s `DelegatingX` and mixes in
`ChangeNotifier` — implements `List`/`Set`/`Map` (`dart:core`) or `Queue`
(`dart:collection`), plus `ValueListenable<…>`; the constructor copies its
argument like `List.of` / `Set.of` / `Map.of` / `Queue.of`. A `MapNotifier`
always stores a `LinkedHashMap` and a `SetNotifier` a `LinkedHashSet` —
insertion order, `==`/`hashCode` equality — so a `SplayTreeMap`'s sort order or
an identity set's equality is not kept. The classes are `final`: hold a notifier
in a field instead of extending or implementing one.

---

## Use it in widgets

### With hooks (recommended)

The hook owns the lifecycle: it creates the notifier on the first build,
rebuilds the host widget on every real change, and disposes the notifier on
unmount. The [Quick start](#quick-start) widget is the whole pattern.

`initial` is consumed **once**. Pass `keys` (`useListNotifier(seed, [dep])`) to
dispose the notifier and create a fresh one from the current `initial` when a
dependency changes, or re-key the host widget.

If the notifier is owned upstream (Riverpod, parent widget), subscribe without
recreating it:

```dart
class const TodoCount(final ListNotifier<String> todos, {super.key})
    extends HookWidget {
  @override
  Widget build(BuildContext context) {
    useListenable(todos);
    return Text('${todos.length} todos');
  }
}
```

### Without hooks

Without `flutter_hooks` widgets, fall back to `ValueListenableBuilder` — the
notifier exposes itself as the value:

```dart
final todos = ListNotifier<String>(['buy milk']);

ValueListenableBuilder<List<String>>(
  valueListenable: todos,
  builder: (context, items, _) => Column(
    children: [for (final t in items) Text(t)],
  ),
);
```

Then `todos` is yours to dispose: in `State.dispose`, with `ref.onDispose`, or
by creating it inside a `ChangeNotifierProvider`, which disposes what it
creates.

### Riverpod

Riverpod 3 moved `ChangeNotifierProvider` to `legacy.dart`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final todosProvider = ChangeNotifierProvider<ListNotifier<String>>((ref) {
  return ListNotifier<String>(['initial']);
});

class const TodoList({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);
    return Column(children: [for (final t in todos) Text(t)]);
  }
}
```

---

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
differ.

### Exceptions

- `ListNotifier.shuffle` on `length > 1` **always** notifies, even when the
  order happens to stay the same.
- `ListNotifier.sort` is silent when the list is already sorted.

### Misuse throws

In every build mode, before anything changes:

- A disposed notifier throws `StateError` from every mutator, `batch`,
  `notifyListeners`, `addListener`, and a second `dispose()`. Reads and
  `removeListener` still work.
- `batch` with an `async` body throws `ArgumentError` without running it —
  changes made after an `await` can't be coalesced.

---

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

---

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

---

## Migration 1.x → 2.x

**Breaking:** `SetNotifier.invert(e)` return value:

```dart
final selected = SetNotifier<int>();
// v1.x — returned whichever of add()/remove() ran
// v2.x — true if element was added, false if removed
final added = selected.invert(1);
```

---

## Agent skill

This package ships an agent skill in `skills/collection-notifiers-usage/`.
Install it into your project's agent config with:

```sh
dart run skills@ get --package collection_notifiers --all
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

[pub-badge]: https://img.shields.io/pub/v/collection_notifiers.svg
[pub]: https://pub.dev/packages/collection_notifiers
[points-badge]: https://img.shields.io/pub/points/collection_notifiers
[points]: https://pub.dev/packages/collection_notifiers/score
[ci-badge]:
  https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml/badge.svg
[ci]: https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml
[license-badge]: https://img.shields.io/badge/license-MIT-blue.svg
