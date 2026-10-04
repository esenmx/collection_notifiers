// Sweep repro: VLB panels place state-dependent _Controls outside the
// ValueListenableBuilder, so button enablement never refreshes.
import 'package:example/src/list_tab.dart';
import 'package:example/src/map_tab.dart';
import 'package:example/src/queue_tab.dart';
import 'package:example/src/set_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpTab(WidgetTester tester, Widget tab) async {
  tester.view.physicalSize = const Size(1200, 2400);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: tab)));
}

ButtonStyleButton button(WidgetTester tester, String label, int panel) {
  final finder = find.ancestor(
    of: find.text(label),
    matching: find.bySubtype<ButtonStyleButton>(),
  );
  return tester.widget<ButtonStyleButton>(finder.at(panel));
}

void main() {
  testWidgets('Queue VLB panel: "Remove first" enables after "Add last"', (
    tester,
  ) async {
    await pumpTab(tester, const QueueTab());
    await tester.tap(find.text('Add last').at(1)); // panel 1 = VLB
    await tester.pump();
    expect(find.textContaining('Last ').evaluate(), isNotEmpty);
    expect(button(tester, 'Remove first', 1).onPressed, isNotNull);
  });

  testWidgets('Set VLB panel: "Clear selection" enables after selecting', (
    tester,
  ) async {
    await pumpTab(tester, const SetTab());
    await tester.tap(find.byType(CheckboxListTile).at(10)); // first VLB row
    await tester.pump();
    expect(button(tester, 'Clear selection', 1).onPressed, isNotNull);
  });

  testWidgets('List VLB panel: "Remove last" disables once empty', (
    tester,
  ) async {
    await pumpTab(tester, const ListTab());
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Remove last').at(1));
      await tester.pump();
    }
    expect(button(tester, 'Remove last', 1).onPressed, isNull);
  });

  testWidgets('Map: "Add item" after a delete always adds a row', (
    tester,
  ) async {
    await pumpTab(tester, const MapTab());
    final rows = find.byType(ListTile);
    await tester.tap(find.text('Add item').first); // adds "Item 4"
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete).first); // delete Apples
    await tester.pump();
    final before = rows.evaluate().length;
    await tester.tap(find.text('Add item').first); // "Item 4" again
    await tester.pump();
    expect(rows.evaluate().length, before + 1);
  });
}
