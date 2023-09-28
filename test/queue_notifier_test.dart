import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('QueueNotifier.of', () {
    test('.new', () {
      final elements = 10.rangeRand();
      final listener = VoidListener();
      final list = QueueNotifier<int>(elements)..addListener(listener);
      expect(list.value, elements);
      listener.verifyNotCalled;
      verifyZeroInteractions(listener);
    });
  });

  group('QueueNotifier', () {
    late VoidListener listener;
    late QueueNotifier<int> notifier;
    setUp(() {
      listener = VoidListener();
      notifier = QueueNotifier<int>()..addListener(listener);
    });
    tearDownAll(() {
      notifier.dispose();
    });

    test('addAll', () {
      notifier.addAll(500.range());
      listener.verifyCalledOnce;
      expect(notifier, 500.range());

      notifier.addAll(500.range(500));
      listener.verifyCalledOnce;
      expect(notifier, 1000.range());
    });

    test('addFirst', () {
      notifier.addFirst(1);
      listener.verifyCalledOnce;
      expect(notifier, [1]);

      notifier.addFirst(2);
      listener.verifyCalledOnce;
      expect(notifier, [2, 1]);
    });

    test('addLast', () {
      notifier.addLast(1);
      listener.verifyCalledOnce;
      expect(notifier, [1]);

      notifier.addLast(2);
      listener.verifyCalledOnce;
      expect(notifier, [1, 2]);
    });

    test('clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(notifier.isEmpty, true);

      notifier.addAll(1000.range());
      listener.verifyCalledOnce;
      expect(notifier, 1000.range());
      notifier.clear();
      listener.verifyCalledOnce;
      expect(notifier.isEmpty, true);
    });

    test('remove', () {
      notifier.addAll(1000.range());
      listener.verifyCalledOnce;
      expect(notifier, 1000.range());

      expect(notifier.remove(999), true);
      listener.verifyCalledOnce;
      expect(notifier, 999.range());

      expect(notifier.remove(999), false);
      listener.verifyNotCalled;
      expect(notifier, 999.range());
    });

    test('removeFirst', () {
      notifier.addAll([1, 2]);
      listener.verifyCalledOnce;
      expect(notifier, [1, 2]);

      expect(notifier.removeFirst(), 1);
      listener.verifyCalledOnce;
      expect(notifier, [2]);

      expect(notifier.removeFirst(), 2);
      listener.verifyCalledOnce;
      expect(notifier, []);

      expect(() => notifier.removeFirst(), throwsA(isA<StateError>()));
    });

    test('removeLast', () {
      notifier.addAll([1, 2]);
      listener.verifyCalledOnce;
      expect(notifier, [1, 2]);

      expect(notifier.removeLast(), 2);
      listener.verifyCalledOnce;
      expect(notifier, [1]);

      expect(notifier.removeLast(), 1);
      listener.verifyCalledOnce;
      expect(notifier, []);

      expect(() => notifier.removeLast(), throwsA(isA<StateError>()));
    });

    test('removeWhere', () {
      notifier.addAll(1000.range());
      listener.verifyCalledOnce;
      expect(notifier, 1000.range());

      notifier.removeWhere((element) => element.isEven);
      listener.verifyCalledOnce;
      expect(notifier, 500.rangeOdd());

      notifier.removeWhere((element) => element.isOdd);
      listener.verifyCalledOnce;
      expect(notifier, []);

      notifier.removeWhere((element) => element.isOdd);
      listener.verifyNotCalled;
    });

    test('retainWhere', () {
      notifier.addAll(1000.range());
      listener.verifyCalledOnce;
      expect(notifier, 1000.range());

      notifier.retainWhere((element) => element.isEven);
      listener.verifyCalledOnce;
      expect(notifier, 500.rangeEven());

      notifier.retainWhere((element) => element.isEven);
      listener.verifyNotCalled;
      expect(notifier, 500.rangeEven());

      notifier.retainWhere((element) => element.isOdd);
      listener.verifyCalledOnce;
      expect(notifier, []);

      notifier.retainWhere((element) => element.isOdd);
      listener.verifyNotCalled;
    });
  });
}
