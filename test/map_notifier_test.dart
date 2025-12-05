import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('MapNotifier', () {
    late VoidListener listener;
    late MapNotifier<String, int?> notifier;

    setUp(() {
      listener = VoidListener();
      notifier = MapNotifier<String, int?>()..addListener(listener.call);
    });

    tearDown(() => notifier.dispose());

    group('constructor', () {
      test('creates empty map by default', () {
        check(notifier).isEmpty();
        check(notifier.value).isEmpty();
        listener.verifyNotCalled;
      });

      test('copies initial entries', () {
        final source = {'a': 1, 'b': 2};
        final map = MapNotifier<String, int>(source);
        addTearDown(map.dispose);

        check(map.value).deepEquals({'a': 1, 'b': 2});
        source['c'] = 3;
        check(map.value).deepEquals({'a': 1, 'b': 2}); // Not affected
      });
    });

    group('operator[]=', () {
      test('notifies when adding new key', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;
        check(notifier['a']).equals(1);
      });

      test('notifies when updating value', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        notifier['a'] = 2;
        listener.verifyCalledOnce;
        check(notifier['a']).equals(2);
      });

      test('does not notify when value is same', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        notifier['a'] = 1;
        listener.verifyNotCalled;
      });

      test('handles null values correctly', () {
        notifier['a'] = null;
        listener.verifyCalledOnce;

        notifier['a'] = null;
        listener.verifyNotCalled; // No change

        notifier['a'] = 1;
        listener.verifyCalledOnce;
      });
    });

    group('addAll', () {
      test('notifies when adding new entries', () {
        notifier.addAll({'a': 1, 'b': 2});
        listener.verifyCalledOnce;
        check(notifier).deepEquals({'a': 1, 'b': 2});
      });

      test('notifies when updating existing values', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        notifier.addAll({'a': 2, 'b': 3});
        listener.verifyCalledOnce;
        check(notifier).deepEquals({'a': 2, 'b': 3});
      });

      test('does not notify when all values are same', () {
        notifier.addAll({'a': 1, 'b': 2});
        listener.verifyCalledOnce;

        notifier.addAll({'a': 1, 'b': 2});
        listener.verifyNotCalled;
      });
    });

    group('addEntries', () {
      test('notifies when adding new entries', () {
        notifier.addEntries([const MapEntry('a', 1), const MapEntry('b', 2)]);
        listener.verifyCalledOnce;
        check(notifier).deepEquals({'a': 1, 'b': 2});
      });

      test('does not notify when entries already exist', () {
        notifier.addEntries([const MapEntry('a', 1)]);
        listener.verifyCalledOnce;

        notifier.addEntries([const MapEntry('a', 1)]);
        listener.verifyNotCalled;
      });
    });

    group('clear', () {
      test('notifies when clearing non-empty map', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        notifier.clear();
        listener.verifyCalledOnce;
        check(notifier).isEmpty();
      });

      test('does not notify when clearing empty map', () {
        notifier.clear();
        listener.verifyNotCalled;
      });
    });

    group('putIfAbsent', () {
      test('notifies when key is absent', () {
        final result = notifier.putIfAbsent('a', () => 1);
        listener.verifyCalledOnce;
        check(result).equals(1);
        check(notifier['a']).equals(1);
      });

      test('does not notify when key exists', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        final result = notifier.putIfAbsent('a', () => 2);
        listener.verifyNotCalled;
        check(result).equals(1);
      });
    });

    group('remove', () {
      test('notifies when key is removed', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        final result = notifier.remove('a');
        listener.verifyCalledOnce;
        check(result).equals(1);
        check(notifier.containsKey('a')).isFalse();
      });

      test('does not notify when key does not exist', () {
        final result = notifier.remove('a');
        listener.verifyNotCalled;
        check(result).isNull();
      });

      test('removes null values correctly', () {
        notifier['a'] = null;
        listener.verifyCalledOnce;

        final result = notifier.remove('a');
        listener.verifyCalledOnce;
        check(result).isNull();
        check(notifier.containsKey('a')).isFalse();
      });
    });

    group('removeWhere', () {
      test('notifies when entries are removed', () {
        notifier.addAll({'a': 1, 'b': 2, 'c': 3});
        listener.verifyCalledOnce;

        notifier.removeWhere((key, value) => (value ?? 0) > 1);
        listener.verifyCalledOnce;
        check(notifier).deepEquals({'a': 1});
      });

      test('does not notify when no entries match', () {
        notifier.addAll({'a': 1, 'b': 2});
        listener.verifyCalledOnce;

        notifier.removeWhere((key, value) => (value ?? 0) > 10);
        listener.verifyNotCalled;
      });
    });

    group('update', () {
      test('notifies when value changes', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        final result = notifier.update('a', (v) => (v ?? 0) + 1);
        listener.verifyCalledOnce;
        check(result).equals(2);
      });

      test('does not notify when value is same', () {
        notifier['a'] = 1;
        listener.verifyCalledOnce;

        notifier.update('a', (v) => v);
        listener.verifyNotCalled;
      });

      test('uses ifAbsent when key missing', () {
        final result =
            notifier.update('a', (v) => (v ?? 0) + 1, ifAbsent: () => 5);
        listener.verifyCalledOnce;
        check(result).equals(5);
      });

      test('throws when key missing and no ifAbsent', () {
        check(() => notifier.update('a', (v) => (v ?? 0) + 1))
            .throws<ArgumentError>();
      });
    });

    group('updateAll', () {
      test('notifies when values change', () {
        notifier.addAll({'a': 1, 'b': 2});
        listener.verifyCalledOnce;

        notifier.updateAll((key, value) => (value ?? 0) * 2);
        listener.verifyCalledOnce;
        check(notifier).deepEquals({'a': 2, 'b': 4});
      });

      test('does not notify when no values change', () {
        notifier.addAll({'a': 1, 'b': 2});
        listener.verifyCalledOnce;

        notifier.updateAll((key, value) => value);
        listener.verifyNotCalled;
      });

      test('does not notify on empty map', () {
        notifier.updateAll((key, value) => (value ?? 0) * 2);
        listener.verifyNotCalled;
      });
    });
  });
}
