import 'dart:collection';

import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CollectionNotifiersExample());
}

class CollectionNotifiersExample extends StatelessWidget {
  const CollectionNotifiersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collection Notifiers Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Collection Notifiers'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'List'),
              Tab(text: 'Set'),
              Tab(text: 'Map'),
              Tab(text: 'Queue'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ListExample(),
            SetExample(),
            MapExample(),
            QueueExample(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ListNotifier Example
// -----------------------------------------------------------------------------

final _listNotifier = ListNotifier<String>(['Apple', 'Banana', 'Cherry']);

class ListExample extends StatelessWidget {
  const ListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _listNotifier,
      builder: (context, items, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _listNotifier.add('Item ${items.length + 1}'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          items.isEmpty ? null : _listNotifier.removeLast,
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          items.length > 1 ? _listNotifier.shuffle : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Shuffle'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: items.length,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _listNotifier.removeAt(oldIndex);
                  _listNotifier.insert(newIndex, item);
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey('$index-${items[index]}'),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(items[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _listNotifier.removeAt(index),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// SetNotifier Example
// -----------------------------------------------------------------------------

final _setNotifier = SetNotifier<int>();

class SetExample extends StatelessWidget {
  const SetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _setNotifier,
      builder: (context, selectedIds, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selected: ${selectedIds.length} items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  final isSelected = selectedIds.contains(index);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text('Item $index'),
                    subtitle: Text(isSelected ? 'Selected' : 'Tap to select'),
                    onChanged: (_) => _setNotifier.invert(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: selectedIds.isEmpty ? null : _setNotifier.clear,
                child: const Text('Clear Selection'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// MapNotifier Example
// -----------------------------------------------------------------------------

final _mapNotifier = MapNotifier<String, int>({
  'Apples': 5,
  'Oranges': 3,
  'Bananas': 7,
});

class MapExample extends StatelessWidget {
  const MapExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: _mapNotifier,
      builder: (context, cart, child) {
        final total = cart.values.fold<int>(0, (sum, qty) => sum + qty);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Total items: $total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView(
                children: cart.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text('Quantity: ${entry.value}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: entry.value > 0
                              ? () => _mapNotifier[entry.key] = entry.value - 1
                              : null,
                        ),
                        Text('${entry.value}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () =>
                              _mapNotifier[entry.key] = entry.value + 1,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _mapNotifier.remove(entry.key),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = 'Item ${cart.length + 1}';
                  _mapNotifier[name] = 1;
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// QueueNotifier Example
// -----------------------------------------------------------------------------

final _queueNotifier = QueueNotifier<String>();

class QueueExample extends StatelessWidget {
  const QueueExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Queue<String>>(
      valueListenable: _queueNotifier,
      builder: (context, queue, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _queueNotifier
                          .addFirst('First ${DateTime.now().second}'),
                      icon: const Icon(Icons.first_page),
                      label: const Text('Add First'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _queueNotifier
                          .addLast('Last ${DateTime.now().second}'),
                      icon: const Icon(Icons.last_page),
                      label: const Text('Add Last'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: queue.isEmpty
                  ? const Center(child: Text('Queue is empty'))
                  : ListView.builder(
                      itemCount: queue.length,
                      itemBuilder: (context, index) {
                        final item = queue.elementAt(index);
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(item),
                          trailing: index == 0
                              ? const Chip(label: Text('HEAD'))
                              : index == queue.length - 1
                                  ? const Chip(label: Text('TAIL'))
                                  : null,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          queue.isEmpty ? null : _queueNotifier.removeFirst,
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove First'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          queue.isEmpty ? null : _queueNotifier.removeLast,
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove Last'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
