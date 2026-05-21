import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

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
/// 5. **Coalesced mutations = one rebuild** — three [mutate] calls
///    between two pumps still produce a single rebuild (framework
///    setState batching).
/// 6. **N pumped mutations = N rebuilds** — each `mutate ; pump`
///    increments the counter by one.
/// 7. **No-op mutations = zero rebuilds** — [noOp] calls never advance
///    the counter, proving the notifier's smart-notification path.
/// 8. **Mixed sequence** — interleaved [noOp] and [mutate] only counts
///    the real mutations.
///
/// [mutate] must change the notifier's state on every call (use the
/// notifier's current length to derive unique values). [noOp] must be a
/// guaranteed no-op (reassign same value, add an existing element, add
/// an empty iterable, etc.).
void runHookNotifierTests<N extends ChangeNotifier, I>({
  required String groupName,
  required N Function(I initial) useHook,
  required I initialA,
  required I initialB,
  required void Function(N notifier) mutate,
  required void Function(N notifier) noOp,
  required int Function(N notifier) length,
}) {
  group(groupName, () {
    testWidgets('creates one instance across rebuilds', (tester) async {
      final notifiers = <N>[];

      Widget build(int version) {
        return MaterialApp(
          home: HookBuilder(
            key: const ValueKey('host'),
            builder: (context) {
              notifiers.add(useHook(initialA));
              return Text('v$version', textDirection: .ltr);
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
    });

    testWidgets('disposes notifier on unmount', (tester) async {
      late N captured;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              captured = useHook(initialA);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());

      check(() => mutate(captured)).throws<FlutterError>();
    });

    testWidgets('initial argument is consumed only on first build', (
      tester,
    ) async {
      late N captured;

      Widget build(I initial) {
        return MaterialApp(
          home: HookBuilder(
            key: const ValueKey('host'),
            builder: (context) {
              captured = useHook(initial);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      await tester.pumpWidget(build(initialA));
      final initialLength = length(captured);

      await tester.pumpWidget(build(initialB));

      check(length(captured)).equals(initialLength);
    });

    testWidgets('single mutation triggers exactly one rebuild', (tester) async {
      final harness = await _pumpHarness(tester, useHook, initialA);

      check(harness.buildCount).equals(1);

      mutate(harness.notifier);
      await tester.pump();

      check(harness.buildCount).equals(2);
    });

    testWidgets('three mutations between pumps coalesce into one rebuild', (
      tester,
    ) async {
      final harness = await _pumpHarness(tester, useHook, initialA);

      check(harness.buildCount).equals(1);

      mutate(harness.notifier);
      mutate(harness.notifier);
      mutate(harness.notifier);
      await tester.pump();

      check(harness.buildCount).equals(2);
    });

    testWidgets('N pumped mutations trigger exactly N rebuilds', (
      tester,
    ) async {
      final harness = await _pumpHarness(tester, useHook, initialA);

      check(harness.buildCount).equals(1);

      for (var i = 0; i < 5; i++) {
        mutate(harness.notifier);
        await tester.pump();
      }

      check(harness.buildCount).equals(6);
    });

    testWidgets('no-op mutations do not rebuild the host', (tester) async {
      final harness = await _pumpHarness(tester, useHook, initialA);

      check(harness.buildCount).equals(1);

      for (var i = 0; i < 3; i++) {
        noOp(harness.notifier);
        await tester.pump();
      }

      check(harness.buildCount).equals(1);
    });

    testWidgets('mixed sequence: only real mutations advance the counter', (
      tester,
    ) async {
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
    });
  });
}

class _Harness<N> {
  _Harness(this.notifier);

  final N notifier;
  int buildCount = 0;
}

Future<_Harness<N>> _pumpHarness<N extends ChangeNotifier, I>(
  WidgetTester tester,
  N Function(I initial) useHook,
  I initial,
) async {
  _Harness<N>? harness;

  await tester.pumpWidget(
    MaterialApp(
      home: HookBuilder(
        builder: (context) {
          final notifier = useHook(initial);
          harness ??= _Harness<N>(notifier);
          harness!.buildCount++;
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  return harness!;
}
