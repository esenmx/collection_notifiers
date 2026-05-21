import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

class ListTab extends StatelessWidget {
  const ListTab({super.key});

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
    final notifier = useListNotifier<String>(['Apple', 'Banana', 'Cherry']);
    return Column(
      crossAxisAlignment: .start,
      children: [
        const PanelHeader(label: 'Hooks · useListNotifier'),
        _Controls(notifier: notifier),
        Expanded(child: _ListBody(notifier: notifier)),
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
  final notifier = ListNotifier<String>(['Apple', 'Banana', 'Cherry']);

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
          child: ValueListenableBuilder<List<String>>(
            valueListenable: notifier,
            builder: (context, items, _) => _ListBody(notifier: notifier),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.notifier});

  final ListNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: [
          FilledButton.icon(
            onPressed: () => notifier.add('Item ${notifier.length + 1}'),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
          OutlinedButton.icon(
            onPressed: notifier.isEmpty ? null : notifier.removeLast,
            icon: const Icon(Icons.remove),
            label: const Text('Remove last'),
          ),
          OutlinedButton.icon(
            onPressed: notifier.length > 1 ? notifier.shuffle : null,
            icon: const Icon(Icons.shuffle),
            label: const Text('Shuffle'),
          ),
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({required this.notifier});

  final ListNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifier.length,
      itemBuilder: (context, i) => ListTile(
        dense: true,
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text(notifier[i]),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => notifier.removeAt(i),
        ),
      ),
    );
  }
}
