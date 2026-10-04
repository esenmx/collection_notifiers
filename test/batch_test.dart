import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/utils.dart';

void main() {
  group('batch', () {
    test('clear then addAll is one atomic change', () {
      final seen = <List<int>>[];
      final n = ListNotifier<int>([1, 2]);
      addTearDown(n.dispose);
      n
        ..addListener(() => seen.add(List.of(n)))
        ..batch(() {
          n
            ..clear()
            ..addAll([3]);
        });
      check(seen).deepEquals([
        [3],
      ]);
    });

    test('a body of only no-ops is silent', () {
      final l = VoidListener();
      final n = SetNotifier<int>({1})..addListener(l.call);
      addTearDown(n.dispose);
      n.batch(() {
        n
          ..add(1)
          ..remove(2);
      });
      l.verifyNotCalled;
    });

    test('a body that throws after a change notifies once', () {
      final l = VoidListener();
      final n = QueueNotifier<int>()..addListener(l.call);
      addTearDown(n.dispose);
      check(
        () => n.batch(() {
          n.addLast(1);
          throw StateError('x');
        }),
      ).throws<StateError>();
      check(n.toList()).deepEquals([1]);
      l.verifyCalledOnce;
    });

    test('nested batches notify once', () {
      final l = VoidListener();
      final n = MapNotifier<String, int>()..addListener(l.call);
      addTearDown(n.dispose);
      n.batch(() {
        n['a'] = 1;
        n.batch(() {
          n['b'] = 2;
        });
        n['c'] = 3;
      });
      check(n).deepEquals({'a': 1, 'b': 2, 'c': 3});
      l.verifyCalledOnce;
    });

    test('an async body fails the synchronous assertion', () {
      final n = ListNotifier<int>();
      addTearDown(n.dispose);
      check(() => n.batch(() async {})).throws<AssertionError>();
    });

    test('an explicit notifyListeners inside notifies once', () {
      final l = VoidListener();
      final n = ListNotifier<int>()..addListener(l.call);
      addTearDown(n.dispose);
      n.batch(n.notifyListeners);
      l.verifyCalledOnce;
    });
  });

  group('assignAll', () {
    test('replacing the contents is one atomic change', () {
      final seen = <List<int>>[];
      final n = ListNotifier<int>([1, 2]);
      addTearDown(n.dispose);
      n
        ..addListener(() => seen.add(List.of(n)))
        ..assignAll([3]);
      check(seen).deepEquals([
        [3],
      ]);
    });

    test('equal values are silent but stored', () {
      final l = VoidListener();
      final n = ListNotifier<Entity>([const Entity(1, 'A')])
        ..addListener(l.call)
        ..assignAll([const Entity(1, 'B')]);
      addTearDown(n.dispose);
      check(n.single.label).equals('B');
      l.verifyNotCalled;
    });

    test('different contents notify once', () {
      final l = VoidListener();
      final n = QueueNotifier<int>([1, 2])
        ..addListener(l.call)
        ..assignAll([2, 1]);
      addTearDown(n.dispose);
      check(n.toList()).deepEquals([2, 1]);
      l.verifyCalledOnce;
    });

    test('assigning itself is silent', () {
      final l = VoidListener();
      final n = ListNotifier<int>([1, 2, 3])..addListener(l.call);
      addTearDown(n.dispose);
      n.assignAll(n);
      check(n).deepEquals([1, 2, 3]);
      l.verifyNotCalled;
    });

    test('a set with duplicate input that dedupes to the same is silent', () {
      final l = VoidListener();
      final n = SetNotifier<int>({1, 2})
        ..addListener(l.call)
        ..assignAll([1, 1, 2]);
      addTearDown(n.dispose);
      check(n).deepEquals({1, 2});
      l.verifyNotCalled;
    });

    test('a map order change notifies once', () {
      final l = VoidListener();
      final n = MapNotifier<String, int>({'a': 1, 'b': 2})
        ..addListener(l.call)
        ..assignAll({'b': 2, 'a': 1});
      addTearDown(n.dispose);
      check(n.keys).deepEquals(['b', 'a']);
      l.verifyCalledOnce;
    });
  });

  group('move', () {
    test('moves to the final index with one notification', () {
      final l = VoidListener();
      final n = ListNotifier<String>(['a', 'b', 'c'])
        ..addListener(l.call)
        ..move(0, 2);
      addTearDown(n.dispose);
      check(n).deepEquals(['b', 'c', 'a']);
      l.verifyCalledOnce;
    });

    test('moving to the same index is silent', () {
      final l = VoidListener();
      final n = ListNotifier<String>(['a', 'b', 'c'])
        ..addListener(l.call)
        ..move(1, 1);
      addTearDown(n.dispose);
      check(n).deepEquals(['a', 'b', 'c']);
      l.verifyNotCalled;
    });

    test('an out-of-range index throws before mutating', () {
      final l = VoidListener();
      final n = ListNotifier<String>(['a', 'b', 'c'])..addListener(l.call);
      addTearDown(n.dispose);
      check(() => n.move(0, 3)).throws<RangeError>();
      check(n).deepEquals(['a', 'b', 'c']);
      l.verifyNotCalled;
    });
  });
}
