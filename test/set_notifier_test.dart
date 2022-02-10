import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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
    late SetNotifier<int> set;
    setUp(() {
      listener = VoidListener();
      set = SetNotifier<int>()..addListener(listener);
    });
    tearDownAll(() {
      set.dispose();
    });

    final bulk = <int>[1, 2, 2, 3, 3, 3];

    test('.add', () {
      expect(true, set.add(1));
      listener.verifyCalledOnce;
      expect(set, {1});

      expect(false, set.add(1));
      listener.verifyNotCalled;

      expect(true, set.add(2));
      listener.verifyCalledOnce;
      expect(set, {1, 2});

      expect(true, set.add(3));
      expect(true, set.add(4));
      listener.verifyCalledTwice;
    });

    test('.addAll', () {
      set.addAll(bulk);
      listener.verifyCalledOnce;
      expect(set, {1, 2, 3});
    });

    test('.clear', () {
      set.clear();
      listener.verifyNotCalled;
      expect(true, set.isEmpty);
      set.add(1);
      set.clear();
      listener.verifyCalledTwice;
    });

    test('remove', () {
      expect(false, set.remove(4));
      listener.verifyNotCalled;
      set.addAll(bulk);
      expect(true, set.remove(1));
      listener.verifyCalledTwice;
      expect(set, {3, 2});
    });

    test('removeAll', () {
      set.removeAll([4, 5, 6]);
      listener.verifyNotCalled;
      set.addAll(bulk);
      set.removeAll([3, 4]);
      expect(true, setEquals({1, 2}, set));
      listener.verifyCalledTwice;
    });

    test('removeWhere', () {
      set.addAll(bulk);
      set.removeWhere((element) => element % 2 == 0);
      expect(set, {1, 3});
      listener.verifyCalledTwice;
      set.removeWhere((element) => element > 5);
      listener.verifyNotCalled;
    });

    test('retainAll', () {
      set.addAll(List.generate(10, (index) => index));
      set.retainAll(bulk);
      listener.verifyCalledTwice;
      expect(set, {1, 2, 3});
      set.retainAll(bulk);
      listener.verifyNotCalled;
    });
  });
}
