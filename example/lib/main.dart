import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

final notifier = SetNotifier<int>();

class Home extends StatelessWidget {
  const Home({super.key});

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

class _SnippetHelper extends ConsumerStatefulWidget {
  const _SnippetHelper({super.key});

  @override
  ConsumerState<_SnippetHelper> createState() => _SnippetHelperState();
}

class _SnippetHelperState extends ConsumerState<_SnippetHelper> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  final list = [];

  void before(Object element) {
    // ...
    setState(() {
      list.add(element);
    });
    // ...
  }
}
