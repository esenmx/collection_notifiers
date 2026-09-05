import 'package:flutter/material.dart';

class const PanelHeader({super.key, required final String label})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: .infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
