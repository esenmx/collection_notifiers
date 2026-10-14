import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/widgets.dart';
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
      final notifiers = <MapNotifier<String, int>>[];

      Widget build(int keyVal) {
        return Directionality(
          textDirection: .ltr,
          child: HookBuilder(
            builder: (context) {
              notifiers.add(useMapNotifier<String, int>({'a': 1}, [keyVal]));
              return const SizedBox.shrink();
            },
          ),
        );
      }

      await tester.pumpWidget(build(1));
      final firstNotifier = notifiers.single;

      await tester.pumpWidget(build(2));
      final secondNotifier = notifiers.last;

      check(identical(firstNotifier, secondNotifier)).isFalse();
      check(() => firstNotifier['b'] = 2).throws<StateError>();
    });
  });
}
