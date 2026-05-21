import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

const _seed = <String, int>{'Apples': 5, 'Oranges': 3, 'Bananas': 7};

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(child: _HooksPanel()),
        Divider(height: 1),
        Expanded(child: _VlbPanel()),
      ],
    );
  }
}

class _HooksPanel extends HookWidget {
  const _HooksPanel();

  @override
  Widget build(BuildContext context) {
    final notifier = useMapNotifier<String, int>(_seed);
    return Column(
      crossAxisAlignment: .start,
      children: [
        const PanelHeader(label: 'Hooks · useMapNotifier'),
        _Controls(notifier: notifier),
        Expanded(child: _MapBody(notifier: notifier)),
      ],
    );
  }
}

class _VlbPanel extends StatefulWidget {
  const _VlbPanel();

  @override
  State<_VlbPanel> createState() => _VlbPanelState();
}

class _VlbPanelState extends State<_VlbPanel> {
  final notifier = MapNotifier<String, int>(_seed);

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const PanelHeader(label: 'ValueListenableBuilder · externally owned'),
        _Controls(notifier: notifier),
        Expanded(
          child: ValueListenableBuilder<Map<String, int>>(
            valueListenable: notifier,
            builder: (context, _, _) => _MapBody(notifier: notifier),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.notifier});

  final MapNotifier<String, int> notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: FilledButton.icon(
        onPressed: () {
          final name = 'Item ${notifier.length + 1}';
          notifier[name] = 1;
        },
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody({required this.notifier});

  final MapNotifier<String, int> notifier;

  @override
  Widget build(BuildContext context) {
    final entries = notifier.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        return ListTile(
          dense: true,
          title: Text(entry.key),
          trailing: Row(
            mainAxisSize: .min,
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
