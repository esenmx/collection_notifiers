import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

final setNotifier =
    ChangeNotifierProvider.autoDispose((ref) => SetNotifier<int>([1, 1, 1]));
final listProvider =
    ChangeNotifierProvider((ref) => ListNotifier<int>([1, 2, 3]));
final mapProvider =
    ChangeNotifierProvider((ref) => MapNotifier<String, int>({'a': 1}));

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(mapProvider)['a'] = 1;
    ref.read(listProvider)[0] = 1;
    return Scaffold(
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
