import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

final notifier = ChangeNotifierProvider.autoDispose((ref) => SetNotifier<int>());

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: List.generate(10, (index) => index).map((e) {
            return CheckboxListTile(
              title: Text(e.toString()),
              value: ref.watch(notifier).contains(e),
              onChanged: (value) {
                if (value == true) {
                  ref.read(notifier).add(e);
                } else {
                  ref.read(notifier).remove(e);
                }
              },
            );
          }),
        ).toList(),
      ),
    );
  }
}
