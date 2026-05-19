import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValueListenableBuilder integration', () {
    testWidgets('rebuilds when ListNotifier mutates', (tester) async {
      final notifier = ListNotifier<String>(['a']);
      addTearDown(notifier.dispose);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<List<String>>(
            valueListenable: notifier,
            builder: (context, items, _) {
              buildCount++;
              return Text(items.join(','), textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      check(buildCount).equals(1);
      check(find.text('a').evaluate()).length.equals(1);

      notifier.add('b');
      await tester.pump();

      check(buildCount).equals(2);
      check(find.text('a,b').evaluate()).length.equals(1);
    });

    testWidgets('does not rebuild on no-op assignment', (tester) async {
      final notifier = ListNotifier<String>(['a']);
      addTearDown(notifier.dispose);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<List<String>>(
            valueListenable: notifier,
            builder: (context, items, _) {
              buildCount++;
              return Text(items.join(','), textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      check(buildCount).equals(1);

      notifier[0] = 'a';
      await tester.pump();

      check(buildCount).equals(1);
    });

    testWidgets('MapNotifier with null values rebuilds correctly',
        (tester) async {
      final notifier = MapNotifier<String, int?>();
      addTearDown(notifier.dispose);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<Map<String, int?>>(
            valueListenable: notifier,
            builder: (context, map, _) {
              buildCount++;
              return Text('${map.length}', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      check(buildCount).equals(1);

      notifier.addAll({'a': null});
      await tester.pump();

      check(buildCount).equals(2);
      check(find.text('1').evaluate()).length.equals(1);
    });
  });
}
