# Widgets and state management

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
  nobody.
- **A hook per type does the wiring.** `useListNotifier`, `useSetNotifier`,
  `useMapNotifier` and `useQueueNotifier` create the notifier, rebuild your
  widget when it changes, and dispose it on unmount: no `StatefulWidget`, no
  `dispose`, no builder widget.

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

Each class extends `package:collection`'s `DelegatingX` and mixes in
`ChangeNotifier` — implements `List`/`Set`/`Map` (`dart:core`) or `Queue`
(`dart:collection`), plus `ValueListenable<…>`; the constructor copies its
argument like `List.of` / `Set.of` / `Map.of` / `Queue.of`. A `MapNotifier`
always stores a `LinkedHashMap` and a `SetNotifier` a `LinkedHashSet` —
insertion order, `==`/`hashCode` equality — so a `SplayTreeMap`'s sort order or
an identity set's equality is not kept. The classes are `final`: hold a notifier
in a field instead of extending or implementing one.

## Use it in widgets

### With hooks (recommended)

The hook owns the lifecycle: it creates the notifier on the first build,
rebuilds the host widget on every real change, and disposes the notifier on
unmount. The [Quick start](../README.md#quick-start) widget is the whole
pattern.

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
