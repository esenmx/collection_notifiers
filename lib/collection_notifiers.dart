/// Collection classes with [ChangeNotifier] and [ValueListenable] support.
///
/// Reactive collection wrappers that notify listeners when their contents
/// change, enabling efficient UI rebuilds in Flutter.
///
/// ## Notifiers
///
/// - [ListNotifier] — reactive [List]
/// - [MapNotifier] — reactive [Map]
/// - [SetNotifier] — reactive [Set]
/// - [QueueNotifier] — reactive [Queue]
///
/// ## Recommended: the dedicated hooks
///
/// Every notifier ships with a matching `flutter_hooks` hook that owns
/// the lifecycle: create on first build, dispose on unmount, rebuild
/// the host widget on every change. **Prefer the hooks** — they remove
/// the `StatefulWidget` / `dispose` / `ValueListenableBuilder`
/// boilerplate that older Flutter docs lean on.
///
/// - [useListNotifier]
/// - [useSetNotifier]
/// - [useMapNotifier]
/// - [useQueueNotifier]
///
/// ```dart
/// class Items extends HookWidget {
///   const Items({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final items = useListNotifier<String>(['a', 'b', 'c']);
///     return Column(
///       children: [
///         FilledButton(
///           onPressed: () => items.add('d'),
///           child: const Text('Add'),
///         ),
///         for (final item in items) Text(item),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Fallback: [ValueListenableBuilder]
///
/// When `flutter_hooks` is not on the project's dependency list — or
/// when the notifier is owned by a state-management container such as a
/// Riverpod `ChangeNotifierProvider` — the standard
/// [ValueListenableBuilder] still works. It is a fallback, not a peer
/// to the hook API.
///
/// ## Notification behaviour
///
/// Methods only call [ChangeNotifier.notifyListeners] when the
/// collection actually changes:
///
/// - `set.add(existingElement)` — no notification (already present)
/// - `map['key'] = sameValue` — no notification (value unchanged)
/// - `list.clear()` on an empty list — no notification (nothing to clear)
///
/// Exceptions: [ListNotifier.sort] and [ListNotifier.shuffle] on a list
/// of length > 1 always notify, and [MapNotifier.addEntries] notifies
/// only on length change. See each method's dartdoc for details.
library;

import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:flutter/widgets.dart' show BuildContext, ValueListenableBuilder;
import 'package:flutter_hooks/flutter_hooks.dart' show Hook, HookState, use;

part 'src/list_notifier.dart';
part 'src/map_notifier.dart';
part 'src/queue_notifier.dart';
part 'src/set_notifier.dart';
part 'src/ui/use_list_notifier.dart';
part 'src/ui/use_map_notifier.dart';
part 'src/ui/use_queue_notifier.dart';
part 'src/ui/use_set_notifier.dart';
