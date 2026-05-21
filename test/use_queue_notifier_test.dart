import 'package:collection_notifiers/collection_notifiers.dart';

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
}
