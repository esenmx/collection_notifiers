import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('QueueNotifier', () {
    late VoidListener listener;
    late QueueNotifier<int> notifier;

    setUp(() {
      listener = VoidListener();
      notifier = QueueNotifier<int>()..addListener(listener.call);
    });

    tearDown(() => notifier.dispose());

    group('constructor', () {
      test('creates empty queue by default', () {
        check(notifier.length).equals(0);
        check(notifier.value.length).equals(0);
        listener.verifyNotCalled;
      });

      test('copies initial elements', () {
        final source = [1, 2, 3];
        final queue = QueueNotifier<int>(source);
        addTearDown(queue.dispose);

        check(queue.value.toList()).deepEquals([1, 2, 3]);
        source.add(4);
        check(queue.value.toList()).deepEquals([1, 2, 3]); // Not affected
      });
    });

    group('add', () {
      test('notifies on add', () {
        notifier.add(1);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1]);

        notifier.add(2);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 2]);
      });
    });

    group('addAll', () {
      test('notifies when adding non-empty iterable', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 2, 3]);
      });

      test('does not notify when adding empty iterable', () {
        notifier.addAll(<int>[]);
        listener.verifyNotCalled;
      });
    });

    group('addFirst', () {
      test('notifies on addFirst', () {
        notifier.addFirst(1);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1]);

        notifier.addFirst(2);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([2, 1]);
      });
    });

    group('addLast', () {
      test('notifies on addLast', () {
        notifier.addLast(1);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1]);

        notifier.addLast(2);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 2]);
      });
    });

    group('clear', () {
      test('notifies when clearing non-empty queue', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.clear();
        listener.verifyCalledOnce;
        check(notifier.length).equals(0);
      });

      test('does not notify when clearing empty queue', () {
        notifier.clear();
        listener.verifyNotCalled;
      });
    });

    group('remove', () {
      test('notifies when element is removed', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.remove(2)).isTrue();
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 3]);
      });

      test('does not notify when element not found', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.remove(4)).isFalse();
        listener.verifyNotCalled;
      });
    });

    group('removeFirst', () {
      test('notifies on removeFirst', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.removeFirst()).equals(1);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([2, 3]);
      });

      test('throws on empty queue', () {
        check(() => notifier.removeFirst()).throws<StateError>();
      });
    });

    group('removeLast', () {
      test('notifies on removeLast', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.removeLast()).equals(3);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 2]);
      });

      test('throws on empty queue', () {
        check(() => notifier.removeLast()).throws<StateError>();
      });
    });

    group('removeWhere', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.removeWhere((int e) => e.isEven);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 3]);
      });

      test('does not notify when no elements match', () {
        notifier.addAll([1, 3, 5]);
        listener.verifyCalledOnce;

        notifier.removeWhere((int e) => e.isEven);
        listener.verifyNotCalled;
      });
    });

    group('retainWhere', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.retainWhere((int e) => e.isOdd);
        listener.verifyCalledOnce;
        check(notifier.toList()).deepEquals([1, 3]);
      });

      test('does not notify when all elements retained', () {
        notifier.addAll([1, 3, 5]);
        listener.verifyCalledOnce;

        notifier.retainWhere((int e) => e.isOdd);
        listener.verifyNotCalled;
      });
    });
  });
}
