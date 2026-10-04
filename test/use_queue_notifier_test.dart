import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hook_notifier_test_block.dart';

void main() {
  runHookNotifierTests<QueueNotifier<int>, List<int>>(
    groupName: 'useQueueNotifier',
    useHook: useQueueNotifier<int>,
    initialA: [1],
    initialB: [7, 8, 9],
    mutate: (notifier) => notifier.addLast(notifier.length + 100),
    noOp: (notifier) => notifier.addAll(const <int>[]),
    length: (notifier) => notifier.length,
  );

  group('useQueueNotifier keys parameter', () {
    testWidgets('recreates notifier and disposes old one when keys change', (
      tester,
    ) async {
      late QueueNotifier<int> captured;

      Widget build(int keyVal) {
        return MaterialApp(
          home: HookBuilder(
            builder: (context) {
              captured = useQueueNotifier<int>([1, 2, 3], [keyVal]);
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
      check(() => firstNotifier.addLast(4)).throws<Error>();
    });
  });
}
