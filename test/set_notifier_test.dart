import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('SetNotifier', () {
    late VoidListener listener;
    late SetNotifier<int> notifier;

    setUp(() {
      listener = VoidListener();
      notifier = SetNotifier<int>()..addListener(listener.call);
    });

    tearDown(() => notifier.dispose());

    group('constructor', () {
      test('creates empty set by default', () {
        check(notifier.length).equals(0);
        check(notifier.value.length).equals(0);
        listener.verifyNotCalled;
      });

      test('copies initial elements', () {
        final source = [1, 2, 2, 3];
        final set = SetNotifier<int>(source);
        addTearDown(set.dispose);

        check(set.value).unorderedEquals([1, 2, 3]); // Duplicates removed
      });
    });

    group('add', () {
      test('notifies when element is added', () {
        check(notifier.add(1)).isTrue();
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1]);
      });

      test('does not notify when element already exists', () {
        notifier.add(1);
        listener.verifyCalledOnce;

        check(notifier.add(1)).isFalse();
        listener.verifyNotCalled;
      });
    });

    group('addAll', () {
      test('notifies when new elements are added', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1, 2, 3]);
      });

      test('does not notify when all elements exist', () {
        notifier.addAll([1, 2]);
        listener.verifyCalledOnce;

        notifier.addAll([1, 2]);
        listener.verifyNotCalled;
      });

      test('notifies when at least one new element', () {
        notifier.addAll([1, 2]);
        listener.verifyCalledOnce;

        notifier.addAll([2, 3]);
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1, 2, 3]);
      });
    });

    group('clear', () {
      test('notifies when clearing non-empty set', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.clear();
        listener.verifyCalledOnce;
        check(notifier.length).equals(0);
      });

      test('does not notify when clearing empty set', () {
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
        check(notifier).unorderedEquals([1, 3]);
      });

      test('does not notify when element not found', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.remove(4)).isFalse();
        listener.verifyNotCalled;
      });
    });

    group('removeAll', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.removeAll([2, 4]);
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1, 3]);
      });

      test('does not notify when no elements match', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.removeAll([4, 5]);
        listener.verifyNotCalled;
      });
    });

    group('removeWhere', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.removeWhere((int e) => e.isEven);
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1, 3]);
      });

      test('does not notify when no elements match', () {
        notifier.addAll([1, 3, 5]);
        listener.verifyCalledOnce;

        notifier.removeWhere((int e) => e.isEven);
        listener.verifyNotCalled;
      });
    });

    group('retainAll', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.retainAll([1, 3]);
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1, 3]);
      });

      test('does not notify when all elements retained', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.retainAll([1, 2, 3, 4]);
        listener.verifyNotCalled;
      });

      test('does not notify on empty set', () {
        notifier.retainAll([1, 2, 3]);
        listener.verifyNotCalled;
      });
    });

    group('retainWhere', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.retainWhere((int e) => e.isOdd);
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1, 3]);
      });

      test('does not notify when all elements retained', () {
        notifier.addAll([1, 3, 5]);
        listener.verifyCalledOnce;

        notifier.retainWhere((int e) => e.isOdd);
        listener.verifyNotCalled;
      });
    });

    group('invert', () {
      test('adds element if not present and returns true', () {
        final result = notifier.invert(1);
        check(result).isTrue();
        listener.verifyCalledOnce;
        check(notifier).unorderedEquals([1]);
      });

      test('removes element if present and returns false', () {
        notifier.add(1);
        listener.verifyCalledOnce;

        final result = notifier.invert(1);
        check(result).isFalse();
        listener.verifyCalledOnce;
        check(notifier.length).equals(0);
      });

      test('toggles correctly in sequence', () {
        notifier
          ..invert(1) // Add
          ..invert(1) // Remove
          ..invert(1); // Add
        listener.verifyCalledThrice;
        check(notifier).unorderedEquals([1]);
      });
    });
  });
}
