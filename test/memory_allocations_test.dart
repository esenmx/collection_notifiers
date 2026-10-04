import 'package:checks/checks.dart';
import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterMemoryAllocations', () {
    final factories = <String, ChangeNotifier Function()>{
      'ListNotifier': ListNotifier<int>.new,
      'MapNotifier': MapNotifier<int, int>.new,
      'SetNotifier': SetNotifier<int>.new,
      'QueueNotifier': QueueNotifier<int>.new,
    };

    for (final MapEntry(key: name, value: create) in factories.entries) {
      test('$name reports its creation without a listener', () {
        final events = <ObjectEvent>[];
        void onEvent(ObjectEvent event) => events.add(event);
        FlutterMemoryAllocations.instance.addListener(onEvent);
        addTearDown(
          () => FlutterMemoryAllocations.instance.removeListener(onEvent),
        );

        final n = create();
        addTearDown(n.dispose);

        check(
          events.whereType<ObjectCreated>().where(
            (e) => identical(e.object, n),
          ),
        ).length.equals(1);
      });
    }
  });
}
