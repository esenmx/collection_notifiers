import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  final bulk = <int>[1, 2, 2, 3, 3, 3];
  group('ListNotifier(elements)', () {
    test('.new', () {
      final listener = VoidListener();
      final list = ListNotifier<int>(bulk)..addListener(listener);
      expect(list.value, bulk);
      listener.verifyNotCalled;
    });
  });

  group('ListNotifier', () {
    late VoidListener listener;
    late ListNotifier<int> list;
    setUp(() {
      listener = VoidListener();
      list = ListNotifier<int>()..addListener(listener);
    });
    tearDownAll(() {
      list.dispose();
    });

    test('operator[]=', () {
      list.add(1);
      list[0] = 1;
      listener.verifyCalledOnce;
      expect(() => list[1] = 2, throwsA(isA<RangeError>()));
      list[0] = 1;
      listener.verifyNotCalled;
    });

    test('.add', () {
      list.add(1);
      listener.verifyCalledOnce;
      expect(list, [1]);

      list.add(2);
      list.add(2);
      listener.verifyCalledTwice;
      expect(list, [1, 2, 2]);
    });

    test('.addAll', () {
      list.addAll(bulk);
      listener.verifyCalledOnce;
      expect(list, bulk);
    });

    test('.clear', () {
      list.clear();
      listener.verifyNotCalled;
      expect(true, list.isEmpty);
      list.add(1);
      list.clear();
      listener.verifyCalledTwice;
    });

    test('fillRange', () {
      expect(() => list.fillRange(1, 7), throwsA(isA<TypeError>()));
      expect(() => list.fillRange(1, 7, 1), throwsA(isA<RangeError>()));
      list.addAll([1, 2, 3]);
      list.fillRange(0, 3, 1);
      expect(list, [1, 1, 1]);
      listener.verifyCalledTwice;
      list.fillRange(0, 2, 2);
      expect(list, [2, 2, 1]);
      listener.verifyCalledOnce;
      list.fillRange(0, 2, 2);
      listener.verifyNotCalled;
    });

    test('insert', () {
      list.addAll(List.generate(3, (index) => index));
      listener.verifyCalledOnce;
      list.insert(2, 1);
      expect(list, [0, 1, 1, 2]);
      listener.verifyCalledOnce;
      list.insert(2, 1);
      expect(list, [0, 1, 1, 1, 2]);
      listener.verifyCalledOnce;
    });

    test('insertAll', () {
      list.insertAll(0, [1, 2, 3]);
      listener.verifyCalledOnce;
      expect(list, [1, 2, 3]);

      expect(() => list.insertAll(5, []), isA<void>());
      expect(() => list.insertAll(5, [1]), throwsA(isA<RangeError>()));
      list.insertAll(1, []);
      listener.verifyNotCalled;
      expect(list, [1, 2, 3]);
    });

    test('remove', () {
      expect(false, list.remove(4));
      listener.verifyNotCalled;
      list.addAll(bulk);
      expect(true, list.remove(1));
      listener.verifyCalledTwice;
      expect(list, [2, 2, 3, 3, 3]);
    });

    test('removeAt', () {
      expect(() => list.removeAt(2), throwsA(isA<RangeError>()));
      list.addAll(bulk);
      list
        ..removeAt(2)
        ..removeAt(3);
      expect(list, [1, 2, 3, 3]);
      listener.verifyCalledThrice;
    });

    test('removeRange', () {
      list.addAll(bulk);
      list.removeRange(2, 4);
      listener.verifyCalledTwice;
      expect(list, [1, 2, 3, 3]);
      list.removeRange(2, 2);
      listener.verifyNotCalled;
      list.removeRange(2, list.length);
      expect(list, [1, 2]);
      listener.verifyCalledOnce;
    });

    test('removeLast', () {
      expect(() => list.removeLast(), throwsA(isA<RangeError>()));
      list.addAll(bulk);
      expect(3, list.removeLast());
      listener.verifyCalledTwice;
      expect(3, list.removeLast());
      listener.verifyCalledOnce;
    });

    test('removeWhere', () {
      list.addAll(bulk);
      list.removeWhere((element) => element % 2 == 1);
      expect(list, [2, 2]);
      listener.verifyCalledTwice;
      list.removeWhere((element) => element > 5);
      listener.verifyNotCalled;
    });

    test('replaceRange', () {
      list.addAll(bulk);
      list.replaceRange(0, list.length, [6, 5, 4]);
      listener.verifyCalledTwice;
      expect(list, [6, 5, 4]);
      expect(() => list.replaceRange(5, 8, {1}), throwsA(isA<RangeError>()));
      listener.verifyNotCalled;
      list.replaceRange(1, 1, [1, 2]);
      listener.verifyNotCalled;
    });

    test('retainWhere', () {
      list.addAll(List.generate(10, (index) => index));
      list.retainWhere((e) => bulk.contains(e));
      listener.verifyCalledTwice;
      expect(list, {1, 2, 3});
      list.retainWhere((e) => bulk.contains(e));
      listener.verifyNotCalled;
      expect(list, {1, 2, 3});
    });

    const testValue = [1, 2, 3];
    test('setAll', () {
      expect(() => list.setAll(1, testValue), throwsA(isA<RangeError>()));
      list.addAll(testValue);
      list.setAll(0, testValue);
      listener.verifyCalledTwice;
      expect(list, testValue);
      list.setAll(2, [4]);
      expect(list, [1, 2, 4]);
      listener.verifyCalledOnce;
    });

    test('setRange', () {
      list.addAll(testValue);
      list.setRange(1, 2, [2, 3]);
      listener.verifyCalledTwice;
      expect(list, [1, 2, 3]);
      list.setRange(0, 1, [3, 1], 1);
      listener.verifyCalledOnce;
      expect(list, [1, 2, 3]);
      list.setRange(1, 1, [1, 2, 3]);
      listener.verifyNotCalled;
    });

    test('shuffle', () {
      list.addAll(bulk);
      list.shuffle();
      listener.verifyCalledTwice;
    });

    test('sort', () {
      list.addAll(bulk);
      list.sort((a, b) => a - b);
      listener.verifyCalledTwice;
    });
  });
}
