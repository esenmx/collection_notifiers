import 'package:example/src/riverpod.dart';
import 'package:example/src/value_listenable.dart';
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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            child: const Text('Riverpod Example'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const RiverpodPage();
              }));
            },
          ),
          ElevatedButton(
            child: const Text('ValueListenable Example'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ValueListenablePage();
              }));
            },
          ),
        ],
      ),
    );
  }
}
