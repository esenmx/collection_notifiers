import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/hook_notifier_test_block.dart';

void main() {
  runHookNotifierTests<MapNotifier<String, int>, Map<String, int>>(
    groupName: 'useMapNotifier',
    useHook: useMapNotifier<String, int>,
    initialA: {'a': 1},
    initialB: {'b': 2, 'c': 3},
    mutate: (notifier) => notifier['k${notifier.length}'] = 99,
    noOp: (notifier) => notifier['a'] = 1,
    length: (notifier) => notifier.length,
  );

  group('useMapNotifier keys parameter', () {
    testWidgets('recreates notifier and disposes old one when keys change', (
      tester,
    ) async {
      late MapNotifier<String, int> captured;

      Widget build(int keyVal) {
        return MaterialApp(
          home: HookBuilder(
            builder: (context) {
              captured = useMapNotifier<String, int>({'a': 1}, [keyVal]);
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
      check(() => firstNotifier['b'] = 2).throws<Error>();
    });
  });
}
