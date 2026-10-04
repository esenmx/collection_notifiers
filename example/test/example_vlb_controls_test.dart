import 'package:example/src/list_tab.dart';
import 'package:example/src/map_tab.dart';
import 'package:example/src/queue_tab.dart';
import 'package:example/src/set_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const vlbPanel = 1;

Future<void> pumpTab(WidgetTester tester, Widget tab) async {
  tester.view.physicalSize = const Size(1200, 2400);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: tab)));
}

ButtonStyleButton vlbButton(WidgetTester tester, String label) {
  final finder = find.ancestor(
    of: find.text(label),
    matching: find.bySubtype<ButtonStyleButton>(),
  );
  return tester.widget<ButtonStyleButton>(finder.at(vlbPanel));
}

void main() {
  testWidgets('Queue VLB panel: "Remove first" enables after "Add last"', (
    tester,
  ) async {
    await pumpTab(tester, const QueueTab());
    await tester.tap(find.text('Add last').at(vlbPanel));
    await tester.pump();
    expect(find.textContaining('Last ').evaluate(), isNotEmpty);
    expect(vlbButton(tester, 'Remove first').onPressed, isNotNull);
  });

  testWidgets('Set VLB panel: "Clear selection" enables after selecting', (
    tester,
  ) async {
    await pumpTab(tester, const SetTab());
    final firstVlbCheckbox = find.byType(CheckboxListTile).at(10);
    await tester.tap(firstVlbCheckbox);
    await tester.pump();
    expect(vlbButton(tester, 'Clear selection').onPressed, isNotNull);
  });

  testWidgets('List VLB panel: "Remove last" disables once empty', (
    tester,
  ) async {
    await pumpTab(tester, const ListTab());
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Remove last').at(vlbPanel));
      await tester.pump();
    }
    expect(vlbButton(tester, 'Remove last').onPressed, isNull);
  });

  testWidgets('Map: "Add item" after a delete always adds a row', (
    tester,
  ) async {
    await pumpTab(tester, const MapTab());
    final rows = find.byType(ListTile);
    final addItem = find.text('Add item').first;
    await tester.tap(addItem);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();
    final rowsAfterDelete = rows.evaluate().length;
    await tester.tap(addItem);
    await tester.pump();
    expect(rows.evaluate().length, rowsAfterDelete + 1);
  });
}
