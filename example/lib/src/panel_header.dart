import 'package:flutter/material.dart';

class PanelHeader extends StatelessWidget {
  const PanelHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
