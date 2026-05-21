import 'package:collection_notifiers/collection_notifiers.dart';

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
}
