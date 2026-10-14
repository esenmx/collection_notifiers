import 'package:example/src/list_tab.dart';
import 'package:example/src/map_tab.dart';
import 'package:example/src/queue_tab.dart';
import 'package:example/src/set_tab.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CollectionNotifiersExample());
}

final class const CollectionNotifiersExample({super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collection Notifiers Example',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

final class const _HomePage() extends StatelessWidget {
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
