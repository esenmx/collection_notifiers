import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('SetNotifier.of', () {
    test('new', () {
      final elements = Generator.randElements(1000);
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
      notifier.addAll(Generator.seqElements(1000));
      listener.verifyCalledOnce;
      expect(notifier, Generator.seqElements(1000));

      notifier.addAll(Generator.seqOddElements(500));
      notifier.addAll(Generator.seqEvenElements(500));
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

      notifier.addAll(Generator.seqElements(1000));
      expect(true, notifier.remove(999));
      listener.verifyCalledTwice;
      expect(notifier, Generator.seqElements(999));
    });

    test('removeAll', () {
      notifier.removeAll([1, 2, 3]);
      listener.verifyNotCalled;

      notifier.addAll(Generator.seqElements(1000));
      expect(notifier, Generator.seqElements(1000));
      notifier.removeAll(Generator.seqEvenElements(2000));
      expect(notifier, Generator.seqOddElements(500));
      listener.verifyCalledTwice;
    });

    test('removeWhere', () {
      notifier.removeWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;

      notifier.addAll(Generator.seqElements(1000));
      notifier.removeWhere((element) => element % 2 == 0);
      expect(notifier, Generator.seqOddElements(500));
      listener.verifyCalledTwice;

      notifier.removeWhere((element) => element > 999);
      listener.verifyNotCalled;
    });

    test('retainAll', () {
      notifier.retainAll(Generator.seqElements(10));
      listener.verifyNotCalled;

      notifier.addAll(Generator.seqElements(1000));
      notifier.retainAll(Generator.seqEvenElements(500));
      listener.verifyCalledTwice;
      expect(notifier, Generator.seqEvenElements(500));

      notifier.retainAll(Generator.seqEvenElements(500));
      listener.verifyNotCalled;

      notifier.retainAll(Generator.seqOddElements(500));
      listener.verifyCalledOnce;
      expect(notifier.isEmpty, true);
    });

    test('retainWhere', () {
      notifier.retainWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;

      notifier.addAll(Generator.seqElements(1000));
      notifier.retainWhere((element) => element % 2 == 0);
      expect(notifier, Generator.seqEvenElements(500));
      listener.verifyCalledTwice;

      notifier.retainWhere((element) => element % 2 == 0);
      listener.verifyNotCalled;

      notifier.retainWhere((element) => element > 998);
      listener.verifyCalledOnce;
      expect(notifier.isEmpty, true);
    });
  });
}
