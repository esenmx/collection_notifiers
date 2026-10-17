import 'package:flutter/material.dart';

final class const PanelHeader({required final String label, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: .infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const .symmetric(horizontal: 12, vertical: 6),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
