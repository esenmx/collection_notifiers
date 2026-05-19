# collection_notifiers

[![Pub Version](https://img.shields.io/pub/v/collection_notifiers.svg)](https://pub.dev/packages/collection_notifiers)
[![CI](https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/collection_notifiers/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/esenmx/collection_notifiers/branch/master/graph/badge.svg)](https://codecov.io/gh/esenmx/collection_notifiers)
[![pub points](https://img.shields.io/pub/points/collection_notifiers)](https://pub.dev/packages/collection_notifiers/score)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

> **Reactive collections for Flutter** — Lists, Sets, Maps, and Queues that automatically rebuild your UI when they change.

---

## ✨ Why collection_notifiers?

| Without this package | With collection_notifiers |
|---------------------|---------------------------|
| Create copies on every change | Mutate in place |
| Always triggers rebuilds | Only rebuilds when actually changed |
| Verbose state management code | Clean, simple API |
| Manual equality checks | Automatic optimization |

```dart
// ❌ Traditional approach - creates new objects, always rebuilds
ref.read(provider.notifier).update((state) => {...state, newItem});

// ✅ With collection_notifiers - zero copies, smart rebuilds
ref.read(provider).add(newItem);
```

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  collection_notifiers: ^2.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

### 1. Create a reactive collection

```dart
import 'package:collection_notifiers/collection_notifiers.dart';

// Just like regular collections, but reactive!
final todos = ListNotifier<String>(['Buy milk', 'Walk dog']);
final selectedIds = SetNotifier<int>();
final settings = MapNotifier<String, bool>({'darkMode': false});
```

### 2. Connect to your UI

#### Option A: Using flutter_hooks (Recommended)

This package is designed to work perfectly with [flutter_hooks](https://pub.dev/packages/flutter_hooks). The `useValueListenable` hook automatically handles subscription and disposal:

```dart
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';

class TodoList extends HookWidget {
  final todos = ListNotifier<String>(['Buy milk']);

  @override
  Widget build(BuildContext context) {
    // 🪄 Automatically rebuilds when collection changes
    final items = useValueListenable(todos);
    
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Text(items[index]),
    );
  }
}
```

**Why we recommend hooks:**

- ✂️ **Zero Boilerplate**: No `ValueListenableBuilder` nesting
- 🔄 **Auto-Dispose**: Subscriptions are managed automatically
- 🧼 **Cleaner Code**: Reads like synchronous code
- 🧩 **Composable**: Easy to combine with other hooks

#### Option B: Using ValueListenableBuilder

If you're not using hooks, use the standard `ValueListenableBuilder`:

```dart
ValueListenableBuilder<List<String>>(
  valueListenable: todos,
  builder: (context, items, child) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Text(items[index]),
    );
  },
)
```

### 3. Mutate and watch UI update automatically

```dart
todos.add('Call mom');     // ✅ UI rebuilds
todos[0] = 'Buy eggs';     // ✅ UI rebuilds  
todos[0] = 'Buy eggs';     // ⏭️ No rebuild (same value!)
```

---

## 📚 Available Notifiers

| Type | Class | Best For |
|------|-------|----------|
| **List** | `ListNotifier<E>` | Ordered items, indices matter |
| **Set** | `SetNotifier<E>` | Unique items, selections |
| **Map** | `MapNotifier<K,V>` | Key-value data, settings |
| **Queue** | `QueueNotifier<E>` | FIFO/LIFO operations |

---

## 🎯 Smart Notifications

The magic is in the optimization — methods only notify listeners when something **actually changes**:

```dart
final tags = SetNotifier<String>({'flutter', 'dart'});

tags.add('rust');      // 🔔 Notifies — new element added
tags.add('rust');      // 🔕 Silent — already exists

tags.remove('rust');   // 🔔 Notifies — element removed  
tags.remove('rust');   // 🔕 Silent — wasn't there

tags.clear();          // 🔔 Notifies — set emptied
tags.clear();          // 🔕 Silent — already empty
```

Same for Maps:

```dart
final config = MapNotifier<String, int>({'volume': 50});

config['volume'] = 75;   // 🔔 Notifies — value changed
config['volume'] = 75;   // 🔕 Silent — same value
config['bass'] = 30;     // 🔔 Notifies — new key added
```

---

## 💡 Common Patterns

### Selection UI with SetNotifier

Perfect for checkboxes, chips, and multi-select:

```dart
final selected = SetNotifier<int>();

// In your widget
CheckboxListTile(
  value: selected.contains(itemId),
  onChanged: (_) => selected.invert(itemId),  // Toggle with one call!
  title: Text('Item $itemId'),
)
```

The `invert()` method toggles presence:

- If item exists → removes it, returns `false`
- If item missing → adds it, returns `true`

### Settings with MapNotifier

```dart
final settings = MapNotifier<String, dynamic>({
  'darkMode': false,
  'fontSize': 14,
  'notifications': true,
});

// Toggle dark mode
settings['darkMode'] = !settings['darkMode']!;

// Only rebuilds if value actually changes
settings['fontSize'] = 14;  // No rebuild if already 14
```

### Todo List with ListNotifier

```dart
final todos = ListNotifier<Todo>();

// Add
todos.add(Todo(title: 'Learn Flutter'));

// Remove
todos.removeWhere((t) => t.completed);

// Reorder
final item = todos.removeAt(oldIndex);
todos.insert(newIndex, item);

// Sort
todos.sort((a, b) => a.priority.compareTo(b.priority));
```

---

## 🔌 State Management Integration

> **Pro Tip:** As mentioned in the Quick Start, we strongly recommend using [flutter_hooks](https://pub.dev/packages/flutter_hooks) via the `useValueListenable` hook for the cleanest, most idiomatic code.

### With Riverpod

```dart
final todosProvider = ChangeNotifierProvider((ref) {
  return ListNotifier<String>(['Initial todo']);
});

// In widget
class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(todos[i]),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => ref.read(todosProvider).removeAt(i),
        ),
      ),
    );
  }
}
```

### With Provider

```dart
ChangeNotifierProvider(
  create: (_) => SetNotifier<int>(),
  child: MyApp(),
)

// In widget
final selected = context.watch<SetNotifier<int>>();
context.read<SetNotifier<int>>().add(itemId);
```

### Vanilla Flutter (no packages)

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _items = ListNotifier<String>();
  
  @override
  void dispose() {
    _items.dispose();  // Don't forget to dispose!
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _items,
      builder: (context, items, _) => /* your UI */,
    );
  }
}
```

---

## ⚠️ Important Notes

### Element Equality

Smart notifications rely on `==` comparison. For custom objects:

```dart
// ❌ Won't work - default object equality
class User {
  final String name;
  User(this.name);
}

// ✅ Works - proper equality
class User {
  final String name;
  User(this.name);
  
  @override
  bool operator ==(Object other) => other is User && other.name == name;
  
  @override
  int get hashCode => name.hashCode;
}
```

**Pro tip:** Use [freezed](https://pub.dev/packages/freezed) or [equatable](https://pub.dev/packages/equatable) for automatic equality.

### Always Dispose

When using in StatefulWidgets, always dispose:

```dart
@override
void dispose() {
  myNotifier.dispose();
  super.dispose();
}
```

### Some Methods Always Notify

`sort()` and `shuffle()` always notify because checking if order changed would be expensive.

---

## 📖 Migration from 1.x

**Breaking change:** `SetNotifier.invert()` return value changed in 2.0.0:

- Now returns `true` if element was **added**
- Now returns `false` if element was **removed**

```dart
// v1.x
selected.invert(1);  // returned result of add() or remove()

// v2.x
selected.invert(1);  // returns true if added, false if removed
```
