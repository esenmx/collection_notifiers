import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:example/src/panel_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final class const SetTab({super.key}) extends StatelessWidget {
  static const _items = 10;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(child: _HooksPanel(total: _items)),
        Divider(height: 1),
        Expanded(child: _VlbPanel(total: _items)),
      ],
    );
  }
}

final class const _HooksPanel({required final int total}) extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = useSetNotifier<int>();
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(
          label: 'Hooks · useSetNotifier (${notifier.length} selected)',
        ),
        _Controls(notifier: notifier),
        Expanded(
          child: _SetBody(notifier: notifier, total: total),
        ),
      ],
    );
  }
}

final class const _VlbPanel({required final int total}) extends StatefulWidget {
  @override
  State<_VlbPanel> createState() => _VlbPanelState();
}

final class _VlbPanelState extends State<_VlbPanel> {
  final notifier = SetNotifier<int>();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: notifier,
      builder: (context, selected, _) => Column(
        crossAxisAlignment: .start,
        children: [
          PanelHeader(
            label: 'ValueListenableBuilder (${selected.length} selected)',
          ),
          _Controls(notifier: notifier),
          Expanded(
            child: _SetBody(notifier: notifier, total: widget.total),
          ),
        ],
      ),
    );
  }
}

final class const _Controls({required final SetNotifier<int> notifier})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(12),
      child: OutlinedButton(
        onPressed: notifier.isEmpty ? null : notifier.clear,
        child: const Text('Clear selection'),
      ),
    );
  }
}

final class const _SetBody({
  required final SetNotifier<int> notifier,
  required final int total,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: total,
      itemBuilder: (context, i) => CheckboxListTile(
        dense: true,
        value: notifier.contains(i),
        title: Text('Item $i'),
        onChanged: (_) => notifier.invert(i),
      ),
    );
  }
}
