import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('SetNotifier(elements)', () {
    test('.new', () {
      final listener = VoidListener();
      final set = SetNotifier<int>([1, 1])..addListener(listener);
      expect(set, {1});
      verifyZeroInteractions(listener);
    });
  });

  group('SetNotifier', () {
    late VoidListener listener;
    late SetNotifier<int> notifier;
    setUp(() {
      listener = VoidListener();
      notifier = SetNotifier<int>()..addListener(listener);
    });
    tearDownAll(() {
      notifier.dispose();
    });

    final bulk = <int>[1, 2, 2, 3, 3, 3];

    test('.add', () {
      expect(true, notifier.add(1));
      listener.verifyCalledOnce;
      expect(notifier, {1});

      expect(false, notifier.add(1));
      listener.verifyNotCalled;

      expect(true, notifier.add(2));
      listener.verifyCalledOnce;
      expect(notifier, {1, 2});

      expect(true, notifier.add(3));
      expect(true, notifier.add(4));
      listener.verifyCalledTwice;
    });

    test('.addAll', () {
      notifier.addAll(bulk);
      listener.verifyCalledOnce;
      expect(notifier, {1, 2, 3});
    });

    test('.clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(true, notifier.isEmpty);
      notifier.add(1);
      notifier.clear();
      listener.verifyCalledTwice;
    });

    test('remove', () {
      expect(false, notifier.remove(4));
      listener.verifyNotCalled;
      notifier.addAll(bulk);
      expect(true, notifier.remove(1));
      listener.verifyCalledTwice;
      expect(notifier, {3, 2});
    });

    test('removeAll', () {
      notifier.removeAll([4, 5, 6]);
      listener.verifyNotCalled;
      notifier.addAll(bulk);
      notifier.removeAll([3, 4]);
      expect(true, setEquals({1, 2}, notifier));
      listener.verifyCalledTwice;
    });

    test('removeWhere', () {
      notifier.addAll(bulk);
      notifier.removeWhere((element) => element % 2 == 0);
      expect(notifier, {1, 3});
      listener.verifyCalledTwice;
      notifier.removeWhere((element) => element > 5);
      listener.verifyNotCalled;
    });

    test('retainAll', () {
      notifier.addAll(List.generate(10, (index) => index));
      notifier.retainAll(bulk);
      listener.verifyCalledTwice;
      expect(notifier, {1, 2, 3});
      notifier.retainAll(bulk);
      listener.verifyNotCalled;
    });
  });
}
