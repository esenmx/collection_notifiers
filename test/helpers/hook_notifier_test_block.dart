import 'package:checks/checks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Runs the canonical lifecycle + smart-notification tests for a
/// `useXNotifier` hook.
///
/// Cases covered:
///
/// 1. **Creates one instance across rebuilds** — pump the same
///    [HookBuilder] three times under a stable key, assert all returned
///    references are `identical`.
/// 2. **Disposes notifier on unmount** — pump, capture the notifier,
///    pump an unrelated widget, assert [mutate] throws.
/// 3. **`initial` is one-time** — pump with [initialA], snapshot via
///    [length], pump again with [initialB], assert snapshot unchanged.
/// 4. **Single mutation = one rebuild** — host build counter advances
///    by exactly one after `mutate ; pump`.
/// 5. **N pumped mutations = N rebuilds** — each `mutate ; pump`
///    increments the counter by one.
/// 6. **No-op mutations = zero rebuilds** — [noOp] calls never advance
///    the counter, proving the notifier's smart-notification path.
/// 7. **Mixed sequence** — interleaved [noOp] and [mutate] only counts
///    the real mutations.
/// 8. **Child [ValueListenableBuilder] follows new notifier on key change** —
///    switching `keys` swaps the underlying notifier and updates a child
///    [ValueListenableBuilder] without throwing.
///
/// [mutate] must change the notifier's state on every call (use the
/// notifier's current length to derive unique values). [noOp] must be a
/// guaranteed no-op (reassign same value, add an existing element, add
/// an empty iterable, etc.).
@isTestGroup
void
runHookNotifierTests<N extends ValueListenable<Object?>, I extends Object>({
  required String groupName,
  required N Function(I initial, [List<Object?>? keys]) useHook,
  required I initialA,
  required I initialB,
  required void Function(N notifier) mutate,
  required void Function(N notifier) noOp,
  required int Function(N notifier) length,
  bool? skip,
  Timeout? timeout,
  Object? tags,
  int? retry,
}) {
  group(groupName, skip: skip, retry: retry, () {
    testWidgets(
      'creates one instance across rebuilds',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final notifiers = <N>[];

        Widget build(int version) {
          return Directionality(
            textDirection: .ltr,
            child: HookBuilder(
              key: const ValueKey('host'),
              builder: (context) {
                notifiers.add(useHook(initialA));
                return Text('v$version');
              },
            ),
          );
        }

        await tester.pumpWidget(build(1));
        await tester.pumpWidget(build(2));
        await tester.pumpWidget(build(3));

        check(notifiers).length.equals(3);
        check(identical(notifiers[0], notifiers[1])).isTrue();
        check(identical(notifiers[1], notifiers[2])).isTrue();
      },
    );

    testWidgets(
      'disposes notifier on unmount',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final notifiers = <N>[];

        await tester.pumpWidget(
          Directionality(
            textDirection: .ltr,
            child: HookBuilder(
              builder: (context) {
                notifiers.add(useHook(initialA));
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        await tester.pumpWidget(const SizedBox.shrink());

        final captured = notifiers.single;
        check(() => mutate(captured)).throws<StateError>();
      },
    );

    testWidgets(
      'initial argument is consumed only on first build',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final notifiers = <N>[];

        Widget build(I initial) {
          return Directionality(
            textDirection: .ltr,
            child: HookBuilder(
              key: const ValueKey('host'),
              builder: (context) {
                notifiers.add(useHook(initial));
                return const SizedBox.shrink();
              },
            ),
          );
        }

        await tester.pumpWidget(build(initialA));
        final initialLength = length(notifiers.last);

        await tester.pumpWidget(build(initialB));

        check(length(notifiers.last)).equals(initialLength);
      },
    );

    testWidgets(
      'single mutation triggers exactly one rebuild',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final harness = await _pumpHarness(tester, useHook, initialA);

        check(harness.buildCount).equals(1);

        mutate(harness.notifier);
        await tester.pump();

        check(harness.buildCount).equals(2);
      },
    );

    testWidgets(
      'N pumped mutations trigger exactly N rebuilds',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final harness = await _pumpHarness(tester, useHook, initialA);

        check(harness.buildCount).equals(1);

        for (var i = 0; i < 5; i++) {
          mutate(harness.notifier);
          await tester.pump();
        }

        check(harness.buildCount).equals(6);
      },
    );

    testWidgets(
      'no-op mutations do not rebuild the host',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final harness = await _pumpHarness(tester, useHook, initialA);

        check(harness.buildCount).equals(1);

        for (var i = 0; i < 3; i++) {
          noOp(harness.notifier);
          await tester.pump();
        }

        check(harness.buildCount).equals(1);
      },
    );

    testWidgets(
      'mixed sequence: only real mutations advance the counter',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        final harness = await _pumpHarness(tester, useHook, initialA);

        check(harness.buildCount).equals(1);

        noOp(harness.notifier);
        await tester.pump();
        check(harness.buildCount).equals(1);

        mutate(harness.notifier);
        await tester.pump();
        check(harness.buildCount).equals(2);

        noOp(harness.notifier);
        await tester.pump();
        check(harness.buildCount).equals(2);

        mutate(harness.notifier);
        await tester.pump();
        check(harness.buildCount).equals(3);

        noOp(harness.notifier);
        await tester.pump();
        check(harness.buildCount).equals(3);
      },
    );

    testWidgets(
      'a child ValueListenableBuilder follows the new notifier on key change',
      skip: skip,
      timeout: timeout,
      tags: tags,
      retry: retry,
      (tester) async {
        Widget build(I initial, int keyVal) {
          return Directionality(
            textDirection: .ltr,
            child: HookBuilder(
              builder: (context) {
                final notifier = useHook(initial, [keyVal]);
                return ValueListenableBuilder<Object?>(
                  valueListenable: notifier,
                  builder: (_, _, _) => Text('len:${length(notifier)}'),
                );
              },
            ),
          );
        }

        await tester.pumpWidget(build(initialA, 1));
        check(find.text('len:${_expectedLength(initialA)}').evaluate()).length
            .equals(1);

        await tester.pumpWidget(build(initialB, 2));

        check(tester.takeException()).isNull();
        check(find.text('len:${_expectedLength(initialB)}').evaluate()).length
            .equals(1);
      },
    );
  });
}

int _expectedLength(Object initial) {
  if (initial is Iterable<Object?>) return initial.length;
  if (initial is Map<Object?, Object?>) return initial.length;
  throw ArgumentError.value(initial, 'initial', 'Expected Iterable or Map');
}

final class _Harness<N>(final N notifier) {
  int buildCount = 0;
}

Future<_Harness<N>>
_pumpHarness<N extends ValueListenable<Object?>, I extends Object>(
  WidgetTester tester,
  N Function(I initial, [List<Object?>? keys]) useHook,
  I initial,
) async {
  _Harness<N>? harness;

  await tester.pumpWidget(
    Directionality(
      textDirection: .ltr,
      child: HookBuilder(
        builder: (context) {
          final notifier = useHook(initial);
          final current = harness ??= _Harness<N>(notifier);
          current.buildCount++;
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  final result = harness;
  if (result == null) {
    throw StateError('HookBuilder did not build');
  }
  return result;
}
