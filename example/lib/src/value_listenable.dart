import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';

class ValueListenablePage extends StatelessWidget {
  const ValueListenablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ValueListenableExample')),
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: SetNotifier<int>(),
        builder: (context, notifier, child) {
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: List.generate(20, (index) {
                return CheckboxListTile(
                  value: notifier.contains(index),
                  title: Text(index.toString()),
                  onChanged: (value) {
                    if (value == true) {
                      notifier.add(index);
                    } else {
                      notifier.remove(index);
                    }
                  },
                );
              }),
            ).toList(),
          );
        },
      ),
    );
  }
}
