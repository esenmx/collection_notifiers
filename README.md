# collection_notifiers

[![pub](https://img.shields.io/pub/v/collection_notifiers.svg)](https://pub.dev/packages/collection_notifiers)
[![CI](https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/esenmx/collection_notifiers/branch/master/graph/badge.svg)](https://codecov.io/gh/esenmx/collection_notifiers)
[![pub points](https://img.shields.io/pub/points/collection_notifiers)](https://pub.dev/packages/collection_notifiers/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Reactive `List` / `Set` / `Map` / `Queue` for Flutter.** Mutate in
place, rebuild on real change only. Ships matching `flutter_hooks`
hooks for one-line widget integration.

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
  [`equatable`](https://pub.dev/packages/equatable) for element types.
- **Not for a single value.** Reach for stdlib `ValueNotifier<T>`.

---

## Install

```bash
flutter pub add collection_notifiers
```

```dart
import 'package:collection_notifiers/collection_notifiers.dart';
```

[`flutter_hooks`](https://pub.dev/packages/flutter_hooks) is a runtime
dependency — the hook variants ship with the package.

---

## Pick the notifier

|Need|Class|Hook|
|---|---|---|
|Ordered, indexable, reorderable|`ListNotifier`|`useListNotifier`|
|Unique elements, selection toggles|`SetNotifier`|`useSetNotifier`|
|Key → value lookup|`MapNotifier`|`useMapNotifier`|
|FIFO/LIFO head-or-tail mutation|`QueueNotifier`|`useQueueNotifier`|

Each class extends `package:collection`'s `DelegatingX` and mixes in
`ChangeNotifier` — drop-in replacement for the matching `dart:core`
collection, plus `ValueListenable<List<E>>` / `<Set<E>>` / `<Map<K, V>>`
/ `<Queue<E>>`.

---

## Hooks — recommended

The hook owns the lifecycle: creates the notifier on first build,
disposes on unmount, rebuilds the host widget on every mutation. Zero
boilerplate.

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

`initial` is consumed **once**. To reset on a dependency change, scope
the host widget under a different `key` so the hook re-mounts.

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

The per-method strategy — length-delta diff, equality-guarded
single-slot, `containsKey` disambiguation for nullable values — is
documented in each method's dartdoc.

### Exceptions

- `ListNotifier.sort` / `shuffle` on `length > 1` **always** notify.
  Verifying order-preservation costs O(n) per call and defeats the
  optimisation budget. Lists of length 0 or 1 short-circuit silently.
- `MapNotifier.addEntries` uses a length-only check: re-inserting an
  existing key with a different value mutates the map but does **not**
  notify. Use `operator []=` or `addAll` when per-key value-diff
  matters.

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
final item = todos.removeAt(oldIndex);
todos.insert(newIndex, item);

// sort always notifies on length > 1 — see "Exceptions"
todos.sort((a, b) => a.priority.compareTo(b.priority));
```

### Riverpod

```dart
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

## Agent setup

A bundled skill ships at
[`skills/flutter-collection-notifiers/SKILL.md`](skills/flutter-collection-notifiers/SKILL.md).
Vendor it into your agent's skill directory
(`~/.claude/skills/flutter-collection-notifiers/`, or the Cursor /
AntiGravity equivalent). It teaches the agent to pick the right
notifier, wire the matching hook, respect dispose discipline, and
stop replacing the collection instead of mutating it.

---

## Pitfalls

|❌|✅|
|---|---|
|`notifier = ListNotifier([...])` — reassigning kills listeners|`notifier..clear()..addAll([...])` — mutate in place|
|Custom element types with default `==` / `hashCode`|`freezed` / `equatable` so equality checks can see real changes|
|`useListNotifier(seed)` with a fresh `seed` per rebuild expecting a reset|`initial` is consumed once — change the host widget's `key` to reset|
|`StatefulWidget` holding a notifier without disposing|Use the matching hook, or override `dispose` and call `notifier.dispose()`|
|Expecting `addEntries` to fire on value change for an existing key|Use `operator []=` / `addAll` — `addEntries` is length-only|

---

## Migration 1.x → 2.x

**Breaking:** `SetNotifier.invert(e)` return value:

```dart
// v1.x — returned whichever of add()/remove() ran
// v2.x — true if element was added, false if removed
selected.invert(1);
```

---

## License

MIT.
