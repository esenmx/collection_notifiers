import 'package:checks/checks.dart';
import 'package:example/src/list_tab.dart';
import 'package:example/src/map_tab.dart';
import 'package:example/src/queue_tab.dart';
import 'package:example/src/set_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const hooksPanel = 0;
const vlbPanel = 1;

Future<void> pumpTab(WidgetTester tester, Widget tab) async {
  tester.view.physicalSize = const Size(1200, 2400);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: tab)));
}

ButtonStyleButton panelButton(WidgetTester tester, String label, int panel) {
  final finder = find.ancestor(
    of: find.text(label),
    matching: find.bySubtype<ButtonStyleButton>(),
  );
  return tester.widget<ButtonStyleButton>(finder.at(panel));
}

void main() {
  group('ListTab', () {
    testWidgets('Hooks & VLB panels: Add and Remove last update state', (
      tester,
    ) async {
      await pumpTab(tester, const ListTab());

      await tester.tap(find.text('Add').at(hooksPanel));
      await tester.pump();
      check(find.text('Item 4').evaluate()).length.equals(1);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Remove last').at(vlbPanel));
        await tester.pump();
      }
      check(panelButton(tester, 'Remove last', vlbPanel).onPressed).isNull();
    });
  });

  group('SetTab', () {
    testWidgets(
      'Hooks & VLB panels: toggling items updates selection and Clear button',
      (tester) async {
        await pumpTab(tester, const SetTab());

        await tester.tap(find.byType(CheckboxListTile).at(0));
        await tester.pump();
        check(panelButton(tester, 'Clear selection', hooksPanel).onPressed)
            .isNotNull();

        final firstVlbCheckbox = find.byType(CheckboxListTile).at(10);
        await tester.tap(firstVlbCheckbox);
        await tester.pump();
        check(panelButton(tester, 'Clear selection', vlbPanel).onPressed)
            .isNotNull();

        await tester.tap(find.text('Clear selection').at(vlbPanel));
        await tester.pump();
        check(panelButton(tester, 'Clear selection', vlbPanel).onPressed)
            .isNull();
      },
    );
  });

  group('MapTab', () {
    testWidgets('Add item after a delete always adds a row in both panels', (
      tester,
    ) async {
      await pumpTab(tester, const MapTab());
      final panels = find.descendant(
        of: find.byType(MapTab),
        matching: find.byType(Expanded),
      );
      for (final panel in [hooksPanel, vlbPanel]) {
        final scope = find.ancestor(
          of: find.text('Add item').at(panel),
          matching: panels,
        );
        Finder inPanel(Finder matching) =>
            find.descendant(of: scope.first, matching: matching);
        final rows = inPanel(find.byType(ListTile));
        final addItem = inPanel(find.text('Add item'));
        await tester.tap(addItem);
        await tester.pump();
        await tester.tap(inPanel(find.byIcon(Icons.delete)).first);
        await tester.pump();
        final rowsAfterDelete = rows.evaluate().length;
        await tester.tap(addItem);
        await tester.pump();
        check(
          rows.evaluate(),
          because: 'panel $panel',
        ).length.equals(rowsAfterDelete + 1);
      }
    });
  });

  group('QueueTab', () {
    testWidgets('Hooks & VLB panels: Add last enables Remove first/last', (
      tester,
    ) async {
      await pumpTab(tester, const QueueTab());

      await tester.tap(find.text('Add first').at(hooksPanel));
      await tester.pump();
      check(find.textContaining('First ').evaluate()).isNotEmpty();
      check(panelButton(tester, 'Remove first', hooksPanel).onPressed)
          .isNotNull();

      await tester.tap(find.text('Add last').at(vlbPanel));
      await tester.pump();
      check(find.textContaining('Last ').evaluate()).isNotEmpty();
      check(panelButton(tester, 'Remove first', vlbPanel).onPressed)
          .isNotNull();
    });
  });
}
