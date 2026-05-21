import 'package:flutter/material.dart';

import 'src/list_tab.dart';
import 'src/map_tab.dart';
import 'src/queue_tab.dart';
import 'src/set_tab.dart';

void main() {
  runApp(const CollectionNotifiersExample());
}

class CollectionNotifiersExample extends StatelessWidget {
  const CollectionNotifiersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collection Notifiers Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Collection Notifiers'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'List'),
              Tab(text: 'Set'),
              Tab(text: 'Map'),
              Tab(text: 'Queue'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ListTab(), SetTab(), MapTab(), QueueTab()],
        ),
      ),
    );
  }
}
