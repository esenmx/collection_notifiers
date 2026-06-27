import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hook_notifier_test_block.dart';

void main() {
  runHookNotifierTests<ListNotifier<int>, List<int>>(
    groupName: 'useListNotifier',
    useHook: useListNotifier<int>,
    initialA: [1, 2, 3],
    initialB: [9, 8, 7, 6],
    mutate: (notifier) => notifier.add(notifier.length + 100),
    noOp: (notifier) => notifier[0] = notifier[0],
    length: (notifier) => notifier.length,
  );

  group('useListNotifier keys parameter', () {
    testWidgets('recreates notifier and disposes old one when keys change', (
      tester,
    ) async {
      late ListNotifier<int> captured;

      Widget build(int keyVal) {
        return MaterialApp(
          home: HookBuilder(
            builder: (context) {
              captured = useListNotifier<int>([1, 2, 3], [keyVal]);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      await tester.pumpWidget(build(1));
      final firstNotifier = captured;

      await tester.pumpWidget(build(2));
      final secondNotifier = captured;

      check(identical(firstNotifier, secondNotifier)).isFalse();
      check(() => firstNotifier.add(4)).throws<FlutterError>();
    });
  });
}
