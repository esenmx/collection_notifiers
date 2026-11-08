import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, FlutterError;
import 'package:flutter_test/flutter_test.dart';

import 'helpers/utils.dart';

extension on Subject<void Function()> {
  void throwsUsedAfterDispose(ChangeNotifier n) {
    this.throws<StateError>().has((e) => e.message, 'message')
      ..contains('used after dispose()')
      ..contains('${n.runtimeType}');
  }
}

void main() {
  group('ListNotifier use after dispose throws StateError', () {
    for (final (name, use) in <(String, void Function(ListNotifier<int>))>[
      ('length=', (n) => n.length = 1),
      ('first=', (n) => n.first = 9),
      ('last=', (n) => n.last = 9),
      ('[]=', (n) => n[0] = 9),
      ('add', (n) => n.add(4)),
      ('addAll', (n) => n.addAll([4])),
      ('clear', (n) => n.clear()),
      ('fillRange', (n) => n.fillRange(0, 1, 9)),
      ('insert', (n) => n.insert(0, 9)),
      ('insertAll', (n) => n.insertAll(0, [9])),
      ('remove', (n) => n.remove(1)),
      ('removeAt', (n) => n.removeAt(0)),
      ('removeRange', (n) => n.removeRange(0, 1)),
      ('removeLast', (n) => n.removeLast()),
      ('removeWhere', (n) => n.removeWhere((e) => e == 1)),
      ('replaceRange', (n) => n.replaceRange(0, 1, [9])),
      ('retainWhere', (n) => n.retainWhere((e) => e == 1)),
      ('setAll', (n) => n.setAll(0, [9])),
      ('setRange', (n) => n.setRange(0, 1, [9])),
      ('shuffle', (n) => n.shuffle()),
      ('sort', (n) => n.sort()),
      ('assignAll', (n) => n.assignAll([9])),
      ('move', (n) => n.move(0, 1)),
      ('batch', (n) => n.batch(() {})),
      ('notifyListeners', (n) => n.notifyListeners()),
      ('addListener', (n) => n.addListener(() {})),
      ('dispose', (n) => n.dispose()),
    ]) {
      test(name, () {
        final n = ListNotifier<int>([3, 1, 2])..dispose();
        check(() => use(n)).throwsUsedAfterDispose(n);
        check(n).deepEquals([3, 1, 2]);
      });
    }
  });

  group('MapNotifier use after dispose throws StateError', () {
    for (final (name, use)
        in <(String, void Function(MapNotifier<String, int>))>[
          ('[]=', (n) => n['b'] = 2),
          ('addAll', (n) => n.addAll({'b': 2})),
          ('addEntries', (n) => n.addEntries([const MapEntry('b', 2)])),
          ('clear', (n) => n.clear()),
          ('putIfAbsent', (n) => n.putIfAbsent('b', () => 2)),
          ('remove', (n) => n.remove('a')),
          ('removeWhere', (n) => n.removeWhere((k, v) => true)),
          ('update', (n) => n.update('a', (v) => v + 1)),
          ('updateAll', (n) => n.updateAll((k, v) => v + 1)),
          ('assignAll', (n) => n.assignAll({'b': 2})),
          ('batch', (n) => n.batch(() {})),
          ('notifyListeners', (n) => n.notifyListeners()),
          ('addListener', (n) => n.addListener(() {})),
          ('dispose', (n) => n.dispose()),
        ]) {
      test(name, () {
        final n = MapNotifier<String, int>({'a': 1})..dispose();
        check(() => use(n)).throwsUsedAfterDispose(n);
        check(n).deepEquals({'a': 1});
      });
    }
  });

  group('SetNotifier use after dispose throws StateError', () {
    for (final (name, use) in <(String, void Function(SetNotifier<int>))>[
      ('add', (n) => n.add(2)),
      ('addAll', (n) => n.addAll([2])),
      ('clear', (n) => n.clear()),
      ('remove', (n) => n.remove(1)),
      ('removeAll', (n) => n.removeAll([1])),
      ('removeWhere', (n) => n.removeWhere((e) => true)),
      ('retainAll', (n) => n.retainAll(<int>[])),
      ('retainWhere', (n) => n.retainWhere((e) => false)),
      ('invert', (n) => n.invert(1)),
      ('assignAll', (n) => n.assignAll([2])),
      ('batch', (n) => n.batch(() {})),
      ('notifyListeners', (n) => n.notifyListeners()),
      ('addListener', (n) => n.addListener(() {})),
      ('dispose', (n) => n.dispose()),
    ]) {
      test(name, () {
        final n = SetNotifier<int>({1})..dispose();
        check(() => use(n)).throwsUsedAfterDispose(n);
        check(n).deepEquals({1});
      });
    }
  });

  group('QueueNotifier use after dispose throws StateError', () {
    for (final (name, use) in <(String, void Function(QueueNotifier<int>))>[
      ('add', (n) => n.add(2)),
      ('addAll', (n) => n.addAll([2])),
      ('addFirst', (n) => n.addFirst(2)),
      ('addLast', (n) => n.addLast(2)),
      ('clear', (n) => n.clear()),
      ('remove', (n) => n.remove(1)),
      ('removeFirst', (n) => n.removeFirst()),
      ('removeLast', (n) => n.removeLast()),
      ('removeWhere', (n) => n.removeWhere((e) => true)),
      ('retainWhere', (n) => n.retainWhere((e) => false)),
      ('assignAll', (n) => n.assignAll([2])),
      ('batch', (n) => n.batch(() {})),
      ('notifyListeners', (n) => n.notifyListeners()),
      ('addListener', (n) => n.addListener(() {})),
      ('dispose', (n) => n.dispose()),
    ]) {
      test(name, () {
        final n = QueueNotifier<int>([1])..dispose();
        check(() => use(n)).throwsUsedAfterDispose(n);
        check(n.toList()).deepEquals([1]);
      });
    }
  });

  group('dispose during a notification', () {
    List<Object> capturedFlutterErrors() {
      TestWidgetsFlutterBinding.ensureInitialized();
      final errors = <Object>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details.exception);
      addTearDown(() => FlutterError.onError = previous);
      return errors;
    }

    void checkDisposedDuringNotification(
      List<Object> errors,
      ListNotifier<int> n,
    ) {
      check(errors).single.isA<StateError>().has((e) => e.message, 'message')
        ..contains('${n.runtimeType}')
        ..contains('during a notification');
    }

    test(
      'from a listener reports StateError and leaves the notifier alive',
      () {
        final errors = capturedFlutterErrors();
        final other = VoidListener();
        final n = ListNotifier<int>();
        n
          ..addListener(n.dispose)
          ..addListener(other.call)
          ..add(1);
        checkDisposedDuringNotification(errors, n);
        other.verifyCalledOnce();

        n
          ..removeListener(n.dispose)
          ..add(2);
        check(n).deepEquals([1, 2]);
        other.verifyCalledOnce();

        n.dispose();
        check(() => n.add(3)).throwsUsedAfterDispose(n);
      },
    );

    test('from the notification a batch sends on exit reports StateError', () {
      final errors = capturedFlutterErrors();
      final n = ListNotifier<int>();
      n
        ..addListener(n.dispose)
        ..batch(() => n.add(1));
      checkDisposedDuringNotification(errors, n);

      n
        ..removeListener(n.dispose)
        ..add(2)
        ..dispose();
    });

    test('from a batch body inside a listener reports StateError', () {
      final errors = capturedFlutterErrors();
      final n = ListNotifier<int>();
      void disposeInBatch() => n.batch(n.dispose);
      n
        ..addListener(disposeInBatch)
        ..add(1);
      checkDisposedDuringNotification(errors, n);

      n
        ..removeListener(disposeInBatch)
        ..add(2)
        ..dispose();
    });

    test('after a nested notification returns still reports StateError', () {
      final errors = capturedFlutterErrors();
      final n = ListNotifier<int>();
      void mutateThenDispose() {
        if (n.length == 1) {
          n
            ..add(2)
            ..dispose();
        }
      }

      n
        ..addListener(mutateThenDispose)
        ..add(1);
      checkDisposedDuringNotification(errors, n);

      n
        ..removeListener(mutateThenDispose)
        ..dispose();
    });

    test('after a re-entrant notification finishes succeeds', () {
      final n = ListNotifier<int>();
      n
        ..addListener(() {
          if (n.length < 3) {
            n.add(n.length);
          }
        })
        ..add(0)
        ..dispose();
      check(() => n.add(9)).throwsUsedAfterDispose(n);
    });
  });

  test('reads and removeListener stay allowed after dispose', () {
    void listener() {}
    final n = ListNotifier<int>([1])
      ..addListener(listener)
      ..dispose()
      ..removeListener(listener);
    check(n.value).deepEquals([1]);
    check(n.contains(1)).isTrue();
  });
}
