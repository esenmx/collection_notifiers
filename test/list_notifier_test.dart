import 'dart:math';

import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('ListNotifier', () {
    late VoidListener listener;
    late ListNotifier<int> notifier;

    setUp(() {
      listener = VoidListener();
      notifier = ListNotifier<int>()..addListener(listener.call);
    });

    tearDown(() => notifier.dispose());

    group('constructor', () {
      test('creates empty list by default', () {
        check(notifier).isEmpty();
        check(notifier.value).isEmpty();
        listener.verifyNotCalled;
      });

      test('copies initial elements', () {
        final source = [1, 2, 3];
        final list = ListNotifier<int>(source);
        addTearDown(list.dispose);

        check(list.value).deepEquals([1, 2, 3]);
        source.add(4);
        check(list.value).deepEquals([1, 2, 3]); // Not affected by source
      });
    });

    group('operator[]=', () {
      test('notifies when value changes', () {
        notifier.add(1);
        listener.verifyCalledOnce;

        notifier[0] = 2;
        listener.verifyCalledOnce;
        check(notifier[0]).equals(2);
      });

      test('does not notify when value is same', () {
        notifier.add(1);
        listener.verifyCalledOnce;

        notifier[0] = 1;
        listener.verifyNotCalled;
      });

      test('throws RangeError for invalid index', () {
        check(() => notifier[0] = 1).throws<RangeError>();
      });
    });

    group('add', () {
      test('notifies on add', () {
        notifier.add(1);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1]);

        notifier.add(1); // Duplicates allowed
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 1]);
      });
    });

    group('addAll', () {
      test('notifies when adding non-empty iterable', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 2, 3]);
      });

      test('does not notify when adding empty iterable', () {
        notifier.addAll([]);
        listener.verifyNotCalled;
      });
    });

    group('clear', () {
      test('notifies when clearing non-empty list', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.clear();
        listener.verifyCalledOnce;
        check(notifier).isEmpty();
      });

      test('does not notify when clearing empty list', () {
        notifier.clear();
        listener.verifyNotCalled;
      });
    });

    group('fillRange', () {
      test('notifies when values change', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.fillRange(0, 3, 0);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([0, 0, 0]);
      });

      test('does not notify when filling with same values', () {
        notifier.addAll([1, 1, 1]);
        listener.verifyCalledOnce;

        notifier.fillRange(0, 3, 1);
        listener.verifyNotCalled;
      });

      test('empty range is no-op and does not require fillValue', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.fillRange(1, 1);
        listener.verifyNotCalled;
        check(notifier).deepEquals([1, 2, 3]);
      });

      test('throws RangeError before cast on invalid range', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(() => notifier.fillRange(0, 99, 0)).throws<RangeError>();
        listener.verifyNotCalled;
      });
    });

    group('insert', () {
      test('notifies on insert', () {
        notifier.insert(0, 1);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1]);

        notifier.insert(0, 2);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([2, 1]);
      });
    });

    group('insertAll', () {
      test('notifies when inserting non-empty iterable', () {
        notifier.insertAll(0, [1, 2]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 2]);
      });

      test('does not notify when inserting empty iterable', () {
        notifier.insertAll(0, []);
        listener.verifyNotCalled;
      });
    });

    group('remove', () {
      test('notifies when element is removed', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.remove(2)).isTrue();
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 3]);
      });

      test('does not notify when element not found', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.remove(4)).isFalse();
        listener.verifyNotCalled;
      });
    });

    group('removeAt', () {
      test('notifies on removeAt', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        check(notifier.removeAt(1)).equals(2);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 3]);
      });

      test('throws RangeError for invalid index', () {
        check(() => notifier.removeAt(0)).throws<RangeError>();
      });
    });

    group('removeRange', () {
      test('notifies when range is removed', () {
        notifier.addAll([1, 2, 3, 4, 5]);
        listener.verifyCalledOnce;

        notifier.removeRange(1, 4);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 5]);
      });

      test('does not notify for empty range', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.removeRange(1, 1);
        listener.verifyNotCalled;
      });
    });

    group('removeLast', () {
      test('notifies on removeLast', () {
        notifier.addAll([1, 2]);
        listener.verifyCalledOnce;

        check(notifier.removeLast()).equals(2);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1]);
      });

      test('throws on empty list', () {
        check(() => notifier.removeLast()).throws<RangeError>();
      });
    });

    group('removeWhere', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.removeWhere((e) => e.isEven);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 3]);
      });

      test('does not notify when no elements match', () {
        notifier.addAll([1, 3, 5]);
        listener.verifyCalledOnce;

        notifier.removeWhere((e) => e.isEven);
        listener.verifyNotCalled;
      });
    });

    group('replaceRange', () {
      test('notifies when range is replaced', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.replaceRange(1, 2, [4, 5]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 4, 5, 3]);
      });

      test('notifies when replacing with empty (deletion)', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.replaceRange(1, 2, []);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 3]);
      });

      test('notifies when inserting via empty range', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.replaceRange(1, 1, [4, 5]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 4, 5, 2, 3]);
      });

      test('does not notify for empty range with empty replacement', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.replaceRange(1, 1, []);
        listener.verifyNotCalled;
      });
    });

    group('retainWhere', () {
      test('notifies when elements are removed', () {
        notifier.addAll([1, 2, 3, 4]);
        listener.verifyCalledOnce;

        notifier.retainWhere((e) => e.isOdd);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 3]);
      });

      test('does not notify when all elements retained', () {
        notifier.addAll([1, 3, 5]);
        listener.verifyCalledOnce;

        notifier.retainWhere((e) => e.isOdd);
        listener.verifyNotCalled;
      });
    });

    group('setAll', () {
      test('notifies when setting elements', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.setAll(0, [4, 5]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([4, 5, 3]);
      });

      test('does not notify for empty iterable', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.setAll(0, []);
        listener.verifyNotCalled;
      });
    });

    group('setRange', () {
      test('notifies when range is set', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.setRange(0, 2, [4, 5]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals([4, 5, 3]);
      });

      test('does not notify for empty range', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.setRange(1, 1, [4, 5]);
        listener.verifyNotCalled;
      });
    });

    group('shuffle', () {
      test('notifies when shuffling list with multiple elements', () {
        notifier.addAll(List.generate(100, (i) => i));
        listener.verifyCalledOnce;

        notifier.shuffle(Random(42));
        listener.verifyCalledOnce;
      });

      test('does not notify for single element list', () {
        notifier.add(1);
        listener.verifyCalledOnce;

        notifier.shuffle();
        listener.verifyNotCalled;
      });

      test('does not notify for empty list', () {
        notifier.shuffle();
        listener.verifyNotCalled;
      });
    });

    group('length setter', () {
      test('notifies when length grows (nullable element type)', () {
        final n = ListNotifier<int?>();
        final l = VoidListener();
        n.addListener(l.call);
        addTearDown(n.dispose);

        n.length = 3;
        l.verifyCalledOnce;
        check(n).deepEquals([null, null, null]);
      });

      test('notifies when length shrinks', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.length = 1;
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1]);
      });

      test('does not notify when length is unchanged', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.length = 3;
        listener.verifyNotCalled;
      });
    });

    group('first setter', () {
      test('notifies when first changes', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.first = 99;
        listener.verifyCalledOnce;
        check(notifier).deepEquals([99, 2, 3]);
      });

      test('does not notify when first is the same', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.first = 1;
        listener.verifyNotCalled;
      });

      test('throws StateError on empty list', () {
        check(() => notifier.first = 1).throws<StateError>();
      });
    });

    group('last setter', () {
      test('notifies when last changes', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.last = 99;
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 2, 99]);
      });

      test('does not notify when last is the same', () {
        notifier.addAll([1, 2, 3]);
        listener.verifyCalledOnce;

        notifier.last = 3;
        listener.verifyNotCalled;
      });

      test('throws StateError on empty list', () {
        check(() => notifier.last = 1).throws<StateError>();
      });
    });

    group('sort', () {
      test('notifies when sorting', () {
        notifier.addAll([3, 1, 2]);
        listener.verifyCalledOnce;

        notifier.sort();
        listener.verifyCalledOnce;
        check(notifier).deepEquals([1, 2, 3]);
      });

      test('does not notify for single element list', () {
        notifier.add(1);
        listener.verifyCalledOnce;

        notifier.sort();
        listener.verifyNotCalled;
      });
    });

    group('listener lifecycle', () {
      test('removeListener stops the removed listener from firing', () {
        final second = VoidListener();
        notifier
          ..addListener(second.call)
          ..add(1);
        listener.verifyCalledOnce;
        second.verifyCalledOnce;

        notifier
          ..removeListener(second.call)
          ..add(2);
        listener.verifyCalledOnce;
        second.verifyNotCalled;
      });

      test('re-entrant mutation inside a listener does not throw', () {
        var fired = 0;
        notifier
          ..addListener(() {
            fired++;
            if (notifier.length < 3) {
              notifier.add(notifier.length);
            }
          })
          ..add(0);

        check(notifier.length).equals(3);
        check(fired).isGreaterThan(0);
      });
    });

    group('dispose', () {
      test('mutating after dispose throws FlutterError', () {
        final n = ListNotifier<int>([1])..dispose();
        check(() => n.add(2)).throws<FlutterError>();
      });
    });

    group('null elements', () {
      test('add/operator[]=/remove work with null values', () {
        final n = ListNotifier<int?>();
        final l = VoidListener();
        n.addListener(l.call);
        addTearDown(n.dispose);

        n.add(null);
        l.verifyCalledOnce;
        check(n).deepEquals([null]);

        n[0] = null;
        l.verifyNotCalled;

        n[0] = 1;
        l.verifyCalledOnce;
        check(n.remove(1)).isTrue();
        l.verifyCalledOnce;
      });
    });
  });
}
