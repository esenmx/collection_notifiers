import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  final bulk = <int>[1, 2, 2, 3, 3, 3];
  group('ListNotifier(elements)', () {
    test('.new', () {
      final listener = VoidListener();
      final list = ListNotifier<int>(bulk)..addListener(listener);
      expect(list.value, bulk);
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
      notifier.addAll(bulk);
      listener.verifyCalledOnce;
      expect(notifier, bulk);
    });

    test('.clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(true, notifier.isEmpty);
      notifier.add(1);
      notifier.clear();
      listener.verifyCalledTwice;
    });

    test('fillRange', () {
      expect(() => notifier.fillRange(1, 7), throwsA(isA<TypeError>()));
      expect(() => notifier.fillRange(1, 7, 1), throwsA(isA<RangeError>()));
      notifier.addAll([1, 2, 3]);
      notifier.fillRange(0, 3, 1);
      expect(notifier, [1, 1, 1]);
      listener.verifyCalledTwice;
      notifier.fillRange(0, 2, 2);
      expect(notifier, [2, 2, 1]);
      listener.verifyCalledOnce;
      notifier.fillRange(0, 2, 2);
      listener.verifyNotCalled;
    });

    test('insert', () {
      notifier.addAll(List.generate(3, (index) => index));
      listener.verifyCalledOnce;
      notifier.insert(2, 1);
      expect(notifier, [0, 1, 1, 2]);
      listener.verifyCalledOnce;
      notifier.insert(2, 1);
      expect(notifier, [0, 1, 1, 1, 2]);
      listener.verifyCalledOnce;
    });

    test('insertAll', () {
      notifier.insertAll(0, [1, 2, 3]);
      listener.verifyCalledOnce;
      expect(notifier, [1, 2, 3]);

      expect(() => notifier.insertAll(5, []), isA<void>());
      expect(() => notifier.insertAll(5, [1]), throwsA(isA<RangeError>()));
      notifier.insertAll(1, []);
      listener.verifyNotCalled;
      expect(notifier, [1, 2, 3]);
    });

    test('remove', () {
      expect(false, notifier.remove(4));
      listener.verifyNotCalled;
      notifier.addAll(bulk);
      expect(true, notifier.remove(1));
      listener.verifyCalledTwice;
      expect(notifier, [2, 2, 3, 3, 3]);
    });

    test('removeAt', () {
      expect(() => notifier.removeAt(2), throwsA(isA<RangeError>()));
      notifier.addAll(bulk);
      notifier
        ..removeAt(2)
        ..removeAt(3);
      expect(notifier, [1, 2, 3, 3]);
      listener.verifyCalledThrice;
    });

    test('removeRange', () {
      notifier.addAll(bulk);
      notifier.removeRange(2, 4);
      listener.verifyCalledTwice;
      expect(notifier, [1, 2, 3, 3]);
      notifier.removeRange(2, 2);
      listener.verifyNotCalled;
      notifier.removeRange(2, notifier.length);
      expect(notifier, [1, 2]);
      listener.verifyCalledOnce;
    });

    test('removeLast', () {
      expect(() => notifier.removeLast(), throwsA(isA<RangeError>()));
      notifier.addAll(bulk);
      expect(3, notifier.removeLast());
      listener.verifyCalledTwice;
      expect(3, notifier.removeLast());
      listener.verifyCalledOnce;
    });

    test('removeWhere', () {
      notifier.addAll(bulk);
      notifier.removeWhere((element) => element % 2 == 1);
      expect(notifier, [2, 2]);
      listener.verifyCalledTwice;
      notifier.removeWhere((element) => element > 5);
      listener.verifyNotCalled;
    });

    test('replaceRange', () {
      notifier.addAll(bulk);
      notifier.replaceRange(0, notifier.length, [6, 5, 4]);
      listener.verifyCalledTwice;
      expect(notifier, [6, 5, 4]);
      expect(
          () => notifier.replaceRange(5, 8, {1}), throwsA(isA<RangeError>()));
      listener.verifyNotCalled;
      notifier.replaceRange(1, 1, [1, 2]);
      listener.verifyNotCalled;
    });

    test('retainWhere', () {
      notifier.addAll(List.generate(10, (index) => index));
      notifier.retainWhere((e) => bulk.contains(e));
      listener.verifyCalledTwice;
      expect(notifier, {1, 2, 3});
      notifier.retainWhere((e) => bulk.contains(e));
      listener.verifyNotCalled;
      expect(notifier, {1, 2, 3});
    });

    const testValue = [1, 2, 3];
    test('setAll', () {
      expect(() => notifier.setAll(1, testValue), throwsA(isA<RangeError>()));
      notifier.addAll(testValue);
      notifier.setAll(0, testValue);
      listener.verifyCalledTwice;
      expect(notifier, testValue);
      notifier.setAll(2, [4]);
      expect(notifier, [1, 2, 4]);
      listener.verifyCalledOnce;
    });

    test('setRange', () {
      notifier.addAll(testValue);
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
      notifier.addAll(bulk);
      notifier.shuffle();
      listener.verifyCalledTwice;
    });

    test('sort', () {
      notifier.addAll(bulk);
      notifier.sort((a, b) => a - b);
      listener.verifyCalledTwice;
    });
  });
}
