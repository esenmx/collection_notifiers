import 'dart:collection';

import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

class QueueTab extends StatefulWidget {
  const QueueTab({super.key});

  @override
  State<QueueTab> createState() => _QueueTabState();
}

class _QueueTabState extends State<QueueTab> {
  final notifier = QueueNotifier<String>();

  void _addFirst() => notifier.addFirst('First ${DateTime.now().second}');
  void _addLast() => notifier.addLast('Last ${DateTime.now().second}');

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
          child: Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _addFirst,
                icon: const Icon(Icons.first_page),
                label: const Text('Add first'),
              ),
              FilledButton.icon(
                onPressed: _addLast,
                icon: const Icon(Icons.last_page),
                label: const Text('Add last'),
              ),
              OutlinedButton.icon(
                onPressed: notifier.isEmpty ? null : notifier.removeFirst,
                icon: const Icon(Icons.remove),
                label: const Text('Remove first'),
              ),
              OutlinedButton.icon(
                onPressed: notifier.isEmpty ? null : notifier.removeLast,
                icon: const Icon(Icons.remove),
                label: const Text('Remove last'),
              ),
            ],
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

  final QueueNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    final queue = useValueListenable(notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'Hooks · useValueListenable'),
        Expanded(child: _QueueList(queue: queue)),
      ],
    );
  }
}

class _VlbPanel extends StatelessWidget {
  const _VlbPanel({required this.notifier});

  final QueueNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'ValueListenableBuilder'),
        Expanded(
          child: ValueListenableBuilder<Queue<String>>(
            valueListenable: notifier,
            builder: (context, queue, _) => _QueueList(queue: queue),
          ),
        ),
      ],
    );
  }
}

class _QueueList extends StatelessWidget {
  const _QueueList({required this.queue});

  final Queue<String> queue;

  @override
  Widget build(BuildContext context) {
    if (queue.isEmpty) {
      return const Center(child: Text('Queue is empty'));
    }
    final items = queue.toList();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        return ListTile(
          dense: true,
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text(items[i]),
          trailing: i == 0
              ? const Chip(label: Text('HEAD'))
              : i == items.length - 1
                  ? const Chip(label: Text('TAIL'))
                  : null,
        );
      },
    );
  }
}
