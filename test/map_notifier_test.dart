import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:test_utils/test_utils.dart';

void main() async {
  group('MapNotifier(elements)', () {
    test('.new', () {
      final listener = VoidListener();
      MapNotifier({1: true}).addListener(listener);
      listener.verifyNotCalled;
      verifyNoMoreInteractions(listener);
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
    });

    test('addAll', () {
      notifier.addAll(Map.fromEntries(Generator.seqEntries(1000)));
      notifier.addAll(Map.fromEntries(Generator.seqEvenEntries(500)));
      listener.verifyCalledOnce;

      notifier.addAll({1000: true});
      listener.verifyCalledOnce;
      expect(notifier.length, 1001);
    });

    test('addEntries', () {
      notifier.addEntries(Generator.seqEntries(1000));
      notifier.addEntries(Generator.seqOddEntries(500));
      listener.verifyCalledOnce;

      notifier.addEntries(const [MapEntry(1001, true)]);
      listener.verifyCalledOnce;
      expect(notifier.length, 1001);
    });

    test('clear', () {
      notifier.clear();
      listener.verifyNotCalled;
      expect(notifier.isEmpty, true);

      notifier.addEntries(Generator.seqEntries(1000));
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
    });

    test('removeWhere', () {
      notifier.addEntries(Generator.seqEvenEntries(100));
      notifier.addEntries(Generator.seqOddEntries(100, false));
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

      notifier.addEntries(Generator.seqEntries(1000));
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
