import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('SetNotifier.of', () {
    test('new', () {
      final elements = 1000.rangeRand();
      final listener = VoidListener();
      final set = SetNotifier<int>(elements)..addListener(listener);
      expect(set.value, elements.toSet());
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

    test('add', () {
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

    test('addAll', () {
      notifier.addAll(1000.range());
      listener.verifyCalledOnce;
      expect(notifier, 1000.range());

      notifier.addAll(500.rangeOdd());
      notifier.addAll(500.rangeEven());
      listener.verifyNotCalled;
    });

    test('clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(true, notifier.isEmpty);

      notifier.add(1);
      notifier.clear();
      listener.verifyCalledTwice;
      expect(true, notifier.isEmpty);
    });

    test('remove', () {
      expect(false, notifier.remove(4));
      listener.verifyNotCalled;

      notifier.addAll(1000.range());
      expect(true, notifier.remove(999));
      listener.verifyCalledTwice;
      expect(notifier, 999.range());
    });

    test('removeAll', () {
      notifier.removeAll([1, 2, 3]);
      listener.verifyNotCalled;

      notifier.addAll(1000.range());
      expect(notifier, 1000.range());
      notifier.removeAll(2000.rangeEven());
      expect(notifier, 500.rangeOdd());
      listener.verifyCalledTwice;
    });

    test('removeWhere', () {
      notifier.removeWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;

      notifier.addAll(1000.range());
      notifier.removeWhere((element) => element % 2 == 0);
      expect(notifier, 500.rangeOdd());
      listener.verifyCalledTwice;

      notifier.removeWhere((element) => element > 999);
      listener.verifyNotCalled;
    });

    test('retainAll', () {
      notifier.retainAll(10.range());
      listener.verifyNotCalled;

      notifier.addAll(1000.range());
      notifier.retainAll(500.rangeEven());
      listener.verifyCalledTwice;
      expect(notifier, 500.rangeEven());

      notifier.retainAll(500.rangeEven());
      listener.verifyNotCalled;

      notifier.retainAll(500.rangeOdd());
      listener.verifyCalledOnce;
      expect(notifier.isEmpty, true);
    });

    test('retainWhere', () {
      notifier.retainWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;

      notifier.addAll(1000.range());
      notifier.retainWhere((element) => element % 2 == 0);
      expect(notifier, 500.rangeEven());
      listener.verifyCalledTwice;

      notifier.retainWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;

      notifier.retainWhere((element) => element > 998);
      listener.verifyCalledOnce;
      expect(notifier.isEmpty, true);
    });

    test('invert', () {
      notifier.invert(42);
      listener.verifyCalledOnce;
      expect(notifier, {42});

      notifier.invert(42);
      expect(notifier, isEmpty);
      listener.verifyCalledOnce;

      notifier.invert(42);
      listener.verifyCalledOnce;
      expect(notifier, {42});
    });
  });
}
