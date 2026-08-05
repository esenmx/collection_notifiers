---
name: flutter-collection-notifiers
version: 1
description: 'Wire reactive List/Set/Map/Queue state in Flutter via `package:collection_notifiers` — selection toggles, multi-select chips, mutable todo lists, key/value settings, in-memory caches, job queues.'
when_to_use: Any in-place collection state driving UI. Not for a single immutable value (`ValueNotifier`).
---

# flutter-collection-notifiers

## Pick the hook

|Need|Hook|
|---|---|
|Ordered, indexable, reorderable|`useListNotifier<E>`|
|Unique elements, selection toggles|`useSetNotifier<E>`|
|Key → value lookup|`useMapNotifier<K, V>`|
|FIFO/LIFO head-or-tail mutation|`useQueueNotifier<E>`|

Each hook creates the notifier, disposes it on unmount, and rebuilds the host widget on every mutation.

## Snippets

```dart
class TodoList extends HookWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = useListNotifier<String>(['Buy milk']);
    return Column(
      children: [
        FilledButton(
          onPressed: () => todos.add('New'),
          child: const Text('Add'),
        ),
        for (final t in todos) Text(t),
      ],
    );
  }
}
```

```dart
class FilterChips extends HookWidget {
  const FilterChips({super.key, required this.tags});

  final List<String> tags;

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

```dart
class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = useMapNotifier<String, bool>({'darkMode': false});
    return SwitchListTile(
      value: settings['darkMode'] ?? false,
      onChanged: (v) => settings['darkMode'] = v,
      title: const Text('Dark mode'),
    );
  }
}
```

```dart
class JobQueueView extends HookWidget {
  const JobQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = useQueueNotifier<String>();
    return Column(
      children: [
        FilledButton(
          onPressed: () => jobs.addLast('Job ${jobs.length + 1}'),
          child: const Text('Enqueue'),
        ),
        for (final j in jobs) Text(j),
      ],
    );
  }
}
```

## Hard rules

- **Mutate, never reassign.** `notifier..clear()..addAll([...])`, never `notifier = ListNotifier(...)`.
- **`initial` is consumed once (unless keys are provided).** To reset, either pass a dependency array `keys` parameter (e.g. `useListNotifier(initial, [dependency])`), or change the host widget's `key` so the hook re-mounts.
- **Element equality is the optimisation contract.** Use `freezed` / `equatable` on custom element types so `==` / `hashCode` are correct.
- **Force rebuilds using `notifyListeners()`.** Since `notifyListeners()` is public on all notifiers, call it to trigger UI updates if you mutate properties of collection elements in-place (which bypasses reference equality).

## When not to use

- **Single immutable value** — use `ValueNotifier<T>` from the SDK.
- **Persisted / undoable state** — pair `drift` with a snapshot table.
- **Cross-isolate state** — `Isolate` + `SendPort`.
