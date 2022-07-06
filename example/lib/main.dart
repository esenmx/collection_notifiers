import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

final notifier = SetNotifier<int>();

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: ValueListenableBuilder<Set<int>>(
        valueListenable: notifier,
        builder: (context, value, child) {
          return ListView(
            children: [
              ...ListTile.divideTiles(
                context: context,
                tiles: List.generate(20, (index) {
                  return CheckboxListTile(
                    value: value.contains(index),
                    title: Text(index.toString()),
                    onChanged: (arg) {
                      if (arg == true) {
                        notifier.add(index);
                      } else {
                        // this is also legit
                        value.remove(index);
                      }
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
