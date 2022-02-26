import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('QueueNotifier.of', () {
    test('.new', () {
      final elements = Generator.randElements(10);
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
      notifier.addAll(Generator.seqElements(500));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(500));

      notifier.addAll(Generator.seqElements(500, 500));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(1000));
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

      notifier.addAll(Generator.seqElements(1000));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(1000));
      notifier.clear();
      listener.verifyCalledOnce;
      expect(notifier.isEmpty, true);
    });

    test('remove', () {
      notifier.addAll(Generator.seqElements(1000));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(1000));

      expect(notifier.remove(999), true);
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(999));

      expect(notifier.remove(999), false);
      listener.verifyNotCalled;
      expect(notifier, Generator.seqElements(999));
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
      notifier.addAll(Generator.seqElements(1000));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(1000));

      notifier.removeWhere((element) => element % 2 == 0);
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqOddElements(500));

      notifier.removeWhere((element) => element % 2 == 1);
      listener.verifyCalledOnce;
      expect(notifier, []);

      notifier.removeWhere((element) => element % 2 == 1);
      listener.verifyNotCalled;
    });

    test('retainWhere', () {
      notifier.addAll(Generator.seqElements(1000));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(1000));

      notifier.retainWhere((element) => element % 2 == 0);
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqEvenElements(500));

      notifier.retainWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;
      expect(notifier, Generator.seqEvenElements(500));

      notifier.retainWhere((element) => element % 2 == 1);
      listener.verifyCalledOnce;
      expect(notifier, []);

      notifier.retainWhere((element) => element % 2 == 1);
      listener.verifyNotCalled;
    });
  });
}
