import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() async {
  group('SetNotifier', () {
    test('.new', () {
      final listener = VoidListener();
      final set = SetNotifier([1, 1])..addListener(listener);
      expect(true, setEquals({1}, set));
      verifyZeroInteractions(listener);
    });

    /// Operations
    late VoidListener listener;
    late SetNotifier<int> set;
    setUp(() {
      listener = VoidListener();
      set = SetNotifier()..addListener(listener);
    });
    tearDownAll(() {
      set.dispose();
    });

    final bulk = <int>[1, 2, 2, 3, 3, 3];

    test('.add', () {
      expect(true, set.add(1));
      verify(listener()).called(1);
      expect(true, setEquals(set, {1}));

      expect(false, set.add(1));
      verifyNever(listener());

      expect(true, set.add(2));
      verify(listener()).called(1);
      expect(true, setEquals(set, {1, 2}));

      expect(true, set.add(3));
      expect(true, set.add(4));
      verify(listener()).called(2);
    });

    test('.clear', () {
      set.clear();
      verifyNever(listener());
      expect(true, set.isEmpty);
      set.add(1);
      set.clear();
      verify(listener()).called(2);
    });

    test('.addAll', () {
      set.addAll(bulk);
      verify(listener()).called(1);
      expect(true, setEquals({1, 2, 3}, set));
    });

    test('remove', () {
      expect(false, set.remove(4));
      verifyNever(listener());
      set.addAll(bulk);
      expect(true, set.remove(1));
      verify(listener()).called(2);
      expect(true, setEquals({3, 2}, set));
    });

    test('removeAll', () {
      set.removeAll([4, 5, 6]);
      verifyNever(listener());
      set.addAll(bulk);
      set.removeAll([3, 4]);
      expect(true, setEquals({1, 2}, set));
      verify(listener()).called(2);
    });
  });
}
