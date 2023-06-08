import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('MapNotifier.of', () {
    test('.new', () {
      final listener = VoidListener();
      final base = Map.fromEntries(100.rangeEntryRand());
      final notifier = MapNotifier(base)..addListener(listener);
      expect(notifier, base);
      expect(notifier.value, base);
      listener.verifyNotCalled;
      verifyZeroInteractions(listener);
    });
  });

  group('MapNotifier', () {
    late VoidListener listener;
    late MapNotifier<int, bool?> notifier;
    setUp(() {
      listener = VoidListener();
      notifier = MapNotifier<int, bool?>()..addListener(listener);
    });
    tearDownAll(() {
      notifier.dispose();
    });

    test('operator[]=', () {
      notifier[1] = true;
      listener.verifyCalledOnce;
      expect(notifier, {1: true});

      notifier[1] = true;
      listener.verifyNotCalled;

      notifier[1] = null;
      notifier[2] = null;
      listener.verifyCalledTwice;

      notifier.value[1] = true;
      listener.verifyCalledOnce;
    });

    test('addAll', () {
      notifier.addAll(Map.fromEntries(1000.rangeEntry()));
      notifier.addAll(Map.fromEntries(500.rangeEntryEven()));
      listener.verifyCalledOnce;
      notifier.addAll(Map.fromEntries(500.rangeEntryEven(false)));
      listener.verifyCalledOnce;
      notifier.addAll(Map.fromEntries(500.rangeEntryEven(false)));
      listener.verifyNotCalled;

      notifier.addAll({1000: true});
      listener.verifyCalledOnce;
      expect(notifier.length, 1001);
    });

    test('addEntries', () {
      notifier.addEntries(1000.rangeEntry());
      notifier.addEntries(500.rangeEntryOdd());
      listener.verifyCalledOnce;

      notifier.addEntries(const [MapEntry(1001, true)]);
      listener.verifyCalledOnce;
      expect(notifier.length, 1001);
    });

    test('clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(notifier.isEmpty, true);

      notifier.addEntries(1000.rangeEntry());
      expect(notifier.length, 1000);
      notifier.clear();
      listener.verifyCalledTwice;
      expect(notifier.isEmpty, true);
    });

    test('putIfAbsent', () {
      notifier.putIfAbsent(1, () => true);
      listener.verifyCalledOnce;
      expect(notifier, {1: true});

      notifier.putIfAbsent(1, () => true);
      listener.verifyNotCalled;
      expect(notifier, {1: true});
    });

    test('remove', () {
      notifier[1] = true;
      notifier.remove(1);
      listener.verifyCalledTwice;
      notifier.remove(1);
      notifier.remove('a');
      listener.verifyNotCalled;
      expect(notifier.isEmpty, true);

      notifier[1] = null;
      listener.verifyCalledOnce;
      notifier.remove(1);
      listener.verifyCalledOnce;
    });

    test('removeWhere', () {
      notifier.addEntries(100.rangeEntryEven());
      notifier.addEntries(100.rangeEntryOdd(false));
      listener.verifyCalledTwice;
      expect(notifier.length, 200);

      notifier.removeWhere((key, value) => value == true);
      listener.verifyCalledOnce;
      expect(notifier.length, 100);

      notifier.removeWhere((key, value) => value == true);
      listener.verifyNotCalled;
      expect(notifier.length, 100);
    });

    test('update', () {
      expect(() => notifier.update(1, (value) => false),
          throwsA(isA<ArgumentError>()));
      listener.verifyNotCalled;
      notifier.update(1, (value) => false, ifAbsent: () => true);
      listener.verifyCalledOnce;

      notifier.update(1, (value) => true);
      listener.verifyNotCalled;
      notifier.update(1, (value) => false);
      listener.verifyCalledOnce;
    });

    test('updateAll', () {
      notifier.updateAll((key, value) => false);
      listener.verifyNotCalled;

      notifier.addEntries(1000.rangeEntry());
      notifier.updateAll((key, value) => key % 2 != 0);
      notifier.removeWhere((key, value) => value != true);
      listener.verifyCalledThrice;
      expect(notifier.length, 500);

      notifier.updateAll((key, value) => key % 5 == 0 ? null : value);
      listener.verifyCalledOnce;
      notifier.removeWhere((key, value) => value == null);
      listener.verifyCalledOnce;
      expect(notifier.length, 400);
    });
  });
}
