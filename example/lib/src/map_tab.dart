import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final notifier = MapNotifier<String, int>({
    'Apples': 5,
    'Oranges': 3,
    'Bananas': 7,
  });

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () {
              final name = 'Item ${notifier.length + 1}';
              notifier[name] = 1;
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _HooksPanel(notifier: notifier)),
        const Divider(height: 1),
        Expanded(child: _VlbPanel(notifier: notifier)),
      ],
    );
  }
}

class _HooksPanel extends HookWidget {
  const _HooksPanel({required this.notifier});

  final MapNotifier<String, int> notifier;

  @override
  Widget build(BuildContext context) {
    final cart = useValueListenable(notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'Hooks · useValueListenable'),
        Expanded(child: _MapList(notifier: notifier, cart: cart)),
      ],
    );
  }
}

class _VlbPanel extends StatelessWidget {
  const _VlbPanel({required this.notifier});

  final MapNotifier<String, int> notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'ValueListenableBuilder'),
        Expanded(
          child: ValueListenableBuilder<Map<String, int>>(
            valueListenable: notifier,
            builder: (context, cart, _) {
              return _MapList(notifier: notifier, cart: cart);
            },
          ),
        ),
      ],
    );
  }
}

class _MapList extends StatelessWidget {
  const _MapList({required this.notifier, required this.cart});

  final MapNotifier<String, int> notifier;
  final Map<String, int> cart;

  @override
  Widget build(BuildContext context) {
    final entries = cart.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        return ListTile(
          dense: true,
          title: Text(entry.key),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: entry.value > 0
                    ? () => notifier[entry.key] = entry.value - 1
                    : null,
              ),
              Text('${entry.value}'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => notifier[entry.key] = entry.value + 1,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => notifier.remove(entry.key),
              ),
            ],
          ),
        );
      },
    );
  }
}
