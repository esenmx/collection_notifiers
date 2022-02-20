import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('ListNotifier.of', () {
    test('.new', () {
      final elements = Generator.randElements(10);
      final listener = VoidListener();
      final list = ListNotifier<int>(elements)..addListener(listener);
      expect(list.value, elements);
      listener.verifyNotCalled;
      verifyNoMoreInteractions(listener);
    });
  });

  group('ListNotifier', () {
    late VoidListener listener;
    late ListNotifier<int> notifier;
    setUp(() {
      listener = VoidListener();
      notifier = ListNotifier<int>()..addListener(listener);
    });
    tearDownAll(() {
      notifier.dispose();
    });

    test('operator[]=', () {
      notifier.add(1);
      notifier[0] = 1;
      listener.verifyCalledOnce;

      expect(() => notifier[1] = 2, throwsA(isA<RangeError>()));

      notifier[0] = 1;
      listener.verifyNotCalled;

      notifier.value[0] = 2;
      listener.verifyCalledOnce;
    });

    test('.add', () {
      notifier.add(1);
      listener.verifyCalledOnce;
      expect(notifier, [1]);

      notifier.add(2);
      notifier.add(2);
      listener.verifyCalledTwice;
      expect(notifier, [1, 2, 2]);
    });

    test('.addAll', () {
      notifier.addAll(Generator.seqElements(100));
      expect(notifier, Generator.seqElements(100));
      listener.verifyCalledOnce;

      notifier.addAll(Generator.seqElements(100));
      notifier.addAll(Generator.seqElements(100));
      listener.verifyCalledTwice;
    });

    test('.clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(true, notifier.isEmpty);

      notifier.add(1);
      notifier.clear();
      listener.verifyCalledTwice;
      expect(true, notifier.isEmpty);
    });

    test('fillRange', () {
      expect(() => notifier.fillRange(0, 0), throwsA(isA<TypeError>()));
      expect(() => notifier.fillRange(0, 1, 0), throwsA(isA<RangeError>()));

      notifier.addAll(Generator.seqElements(100));
      notifier.fillRange(0, 100, 1);
      listener.verifyCalledTwice;
      notifier.fillRange(0, 100, 1);
      listener.verifyNotCalled;
      expect(notifier, List<int>.filled(100, 1));

      notifier.fillRange(0, 2, 2);
      listener.verifyCalledOnce;
      notifier.fillRange(0, 2, 2);
      listener.verifyNotCalled;
    });

    test('insert', () {
      notifier.addAll(Generator.seqElements(1000));
      listener.verifyCalledOnce;

      notifier.insert(2, 1);
      expect(notifier.length, 1001);
      expect(notifier[2], 1);
      listener.verifyCalledOnce;

      notifier.insert(2, 1);
      expect(notifier.length, 1002);
      expect(notifier[2], 1);
      listener.verifyCalledOnce;
    });

    test('insertAll', () {
      expect(() => notifier.insertAll(5, []), isA<void>());
      expect(() => notifier.insertAll(5, [1]), throwsA(isA<RangeError>()));

      notifier.insertAll(0, Generator.seqElements(1000));
      expect(notifier, Generator.seqElements(1000));
      listener.verifyCalledOnce;

      notifier.insertAll(1, []);
      listener.verifyNotCalled;
      expect(notifier, Generator.seqElements(1000));
    });

    test('remove', () {
      expect(false, notifier.remove(0));
      listener.verifyNotCalled;

      notifier.addAll(Generator.seqElements(1000));
      expect(true, notifier.remove(1));
      listener.verifyCalledTwice;

      expect(notifier, Generator.seqElements(1000)..remove(1));
    });

    test('removeAt', () {
      expect(() => notifier.removeAt(2), throwsA(isA<RangeError>()));

      notifier.addAll(Generator.seqElements(1000));
      notifier
        ..removeAt(999)
        ..removeAt(998);
      expect(notifier, Generator.seqElements(998));
      listener.verifyCalledThrice;
    });

    test('removeRange', () {
      notifier.addAll(Generator.seqElements(1000));
      notifier.removeRange(500, 1000);
      listener.verifyCalledTwice;
      expect(notifier, Generator.seqElements(500));

      notifier.removeRange(500, 500);
      listener.verifyNotCalled;

      notifier.removeRange(2, notifier.length);
      expect(notifier, [0, 1]);
      listener.verifyCalledOnce;
    });

    test('removeLast', () {
      notifier.addAll([1, 2]);
      expect(2, notifier.removeLast());
      listener.verifyCalledTwice;
      expect(1, notifier.removeLast());
      listener.verifyCalledOnce;
      expect(() => notifier.removeLast(), throwsA(isA<RangeError>()));
    });

    test('removeWhere', () {
      notifier.addAll(Generator.seqElements(1000));
      notifier.removeWhere((element) => element % 2 == 1);
      expect(notifier, Generator.seqEvenElements(500));
      listener.verifyCalledTwice;

      notifier.removeWhere((element) => element > 1000);
      listener.verifyNotCalled;
    });

    test('replaceRange', () {
      notifier.addAll(Generator.seqElements(1000));
      notifier.replaceRange(0, notifier.length, [1, 2, 3]);
      listener.verifyCalledTwice;
      expect(notifier, [1, 2, 3]);

      expect(
          () => notifier.replaceRange(4, 5, {1}), throwsA(isA<RangeError>()));
      listener.verifyNotCalled;

      notifier.replaceRange(1, 1, [1, 2]);
      listener.verifyNotCalled;
    });

    test('retainWhere', () {
      notifier.addAll(Generator.seqElements(1000));
      final retain = Generator.seqOddElements(500);
      notifier.retainWhere(retain.contains);
      listener.verifyCalledTwice;
      expect(notifier, retain);

      notifier.retainWhere(retain.contains);
      listener.verifyNotCalled;
      expect(notifier, retain);
    });

    test('setAll', () {
      expect(() => notifier.setAll(1, [1]), throwsA(isA<RangeError>()));

      notifier.addAll(Generator.seqElements(500));
      notifier.setAll(0, Generator.seqOddElements(500));
      listener.verifyCalledTwice;
      expect(notifier, Generator.seqOddElements(500));

      notifier.setAll(0, [2]);
      expect(notifier, Generator.seqOddElements(500)..[0] = 2);
      listener.verifyCalledOnce;
    });

    test('setRange', () {
      notifier.addAll([1, 2, 3]);
      notifier.setRange(1, 2, [2, 3]);
      listener.verifyCalledTwice;
      expect(notifier, [1, 2, 3]);
      notifier.setRange(0, 1, [3, 1], 1);
      listener.verifyCalledOnce;
      expect(notifier, [1, 2, 3]);
      notifier.setRange(1, 1, [1, 2, 3]);
      listener.verifyNotCalled;
    });

    test('shuffle', () {
      notifier.addAll(Generator.seqElements(1000));
      notifier.shuffle();
      listener.verifyCalledTwice;
    });

    test('sort', () {
      notifier.addAll(Generator.randElements(1000));
      notifier.sort((a, b) => a - b);
      listener.verifyCalledTwice;
    });
  });
}
