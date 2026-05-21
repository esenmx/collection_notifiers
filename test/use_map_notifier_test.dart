import 'package:collection_notifiers/collection_notifiers.dart';

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
}
