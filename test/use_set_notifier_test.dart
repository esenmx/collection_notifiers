import 'package:collection_notifiers/collection_notifiers.dart';

import 'helpers/hook_notifier_test_block.dart';

void main() {
  runHookNotifierTests<SetNotifier<int>, Set<int>>(
    groupName: 'useSetNotifier',
    useHook: useSetNotifier<int>,
    initialA: {1, 2},
    initialB: {7, 8, 9},
    mutate: (notifier) => notifier.add(notifier.length + 100),
    noOp: (notifier) => notifier.add(1),
    length: (notifier) => notifier.length,
  );
}
