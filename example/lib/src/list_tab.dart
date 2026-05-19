import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final notifier = ListNotifier<String>(['Apple', 'Banana', 'Cherry']);

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Controls(notifier: notifier),
        const Divider(height: 1),
        Expanded(child: _HooksPanel(notifier: notifier)),
        const Divider(height: 1),
        Expanded(child: _VlbPanel(notifier: notifier)),
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

class _HooksPanel extends HookWidget {
  const _HooksPanel({required this.notifier});

  final ListNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    final items = useValueListenable(notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'Hooks · useValueListenable'),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => ListTile(
              dense: true,
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(items[i]),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => notifier.removeAt(i),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VlbPanel extends StatelessWidget {
  const _VlbPanel({required this.notifier});

  final ListNotifier<String> notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'ValueListenableBuilder'),
        Expanded(
          child: ValueListenableBuilder<List<String>>(
            valueListenable: notifier,
            builder: (context, items, _) {
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => ListTile(
                  dense: true,
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(items[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => notifier.removeAt(i),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
