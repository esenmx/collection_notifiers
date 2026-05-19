import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'panel_header.dart';

class SetTab extends StatefulWidget {
  const SetTab({super.key});

  @override
  State<SetTab> createState() => _SetTabState();
}

class _SetTabState extends State<SetTab> {
  final notifier = SetNotifier<int>();
  static const _items = 10;

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
          child: Row(
            children: [
              OutlinedButton(
                onPressed: notifier.isEmpty ? null : notifier.clear,
                child: const Text('Clear selection'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _HooksPanel(notifier: notifier, total: _items)),
        const Divider(height: 1),
        Expanded(child: _VlbPanel(notifier: notifier, total: _items)),
      ],
    );
  }
}

class _HooksPanel extends HookWidget {
  const _HooksPanel({required this.notifier, required this.total});

  final SetNotifier<int> notifier;
  final int total;

  @override
  Widget build(BuildContext context) {
    final selected = useValueListenable(notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelHeader(
          label: 'Hooks · useValueListenable (${selected.length} selected)',
        ),
        Expanded(
          child: ListView.builder(
            itemCount: total,
            itemBuilder: (context, i) => CheckboxListTile(
              dense: true,
              value: selected.contains(i),
              title: Text('Item $i'),
              onChanged: (_) => notifier.invert(i),
            ),
          ),
        ),
      ],
    );
  }
}

class _VlbPanel extends StatelessWidget {
  const _VlbPanel({required this.notifier, required this.total});

  final SetNotifier<int> notifier;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<Set<int>>(
          valueListenable: notifier,
          builder: (context, selected, _) => PanelHeader(
            label:
                'ValueListenableBuilder (${selected.length} selected)',
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<Set<int>>(
            valueListenable: notifier,
            builder: (context, selected, _) {
              return ListView.builder(
                itemCount: total,
                itemBuilder: (context, i) => CheckboxListTile(
                  dense: true,
                  value: selected.contains(i),
                  title: Text('Item $i'),
                  onChanged: (_) => notifier.invert(i),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
