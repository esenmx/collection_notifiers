import 'dart:collection';

import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

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
    final notifier = useQueueNotifier<String>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        const PanelHeader(label: 'Hooks · useQueueNotifier'),
        _Controls(notifier: notifier),
        Expanded(child: _QueueBody(queue: notifier)),
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
  final notifier = QueueNotifier<String>();

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
          child: ValueListenableBuilder<Queue<String>>(
            valueListenable: notifier,
            builder: (context, queue, _) => _QueueBody(queue: queue),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.notifier});

  final QueueNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: [
          FilledButton.icon(
            onPressed: () =>
                notifier.addFirst('First ${DateTime.now().second}'),
            icon: const Icon(Icons.first_page),
            label: const Text('Add first'),
          ),
          FilledButton.icon(
            onPressed: () =>
                notifier.addLast('Last ${DateTime.now().second}'),
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
    );
  }
}

class _QueueBody extends StatelessWidget {
  const _QueueBody({required this.queue});

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
