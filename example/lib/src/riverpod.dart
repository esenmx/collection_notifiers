import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final setNotifier =
    ChangeNotifierProvider.autoDispose((ref) => SetNotifier<int>([1, 1, 1]));

class RiverpodPage extends ConsumerWidget {
  const RiverpodPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Example')),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: List.generate(10, (index) => index).map((e) {
            return CheckboxListTile(
              title: Text(e.toString()),
              value: ref.watch(setNotifier).contains(e),
              onChanged: (value) {
                if (value == true) {
                  ref.read(setNotifier).add(e);
                } else {
                  ref.read(setNotifier).remove(e);
                }
              },
            );
          }),
        ).toList(),
      ),
    );
  }
}
