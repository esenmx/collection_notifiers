/// Collection classes with [ChangeNotifier] and [ValueListenable] support.
///
/// This library provides reactive collection wrappers that notify listeners
/// when their contents change, enabling efficient UI rebuilds in Flutter.
///
/// ## Available Notifiers
///
/// - [ListNotifier] - A reactive [List] implementation
/// - [MapNotifier] - A reactive [Map] implementation
/// - [SetNotifier] - A reactive [Set] implementation
/// - [QueueNotifier] - A reactive [Queue] implementation
///
/// ## Usage with ValueListenableBuilder
///
/// ```dart
/// final items = ListNotifier<String>(['a', 'b', 'c']);
///
/// ValueListenableBuilder<List<String>>(
///   valueListenable: items,
///   builder: (context, value, child) {
///     return ListView.builder(
///       itemCount: value.length,
///       itemBuilder: (context, index) => Text(value[index]),
///     );
///   },
/// );
///
/// // Mutations automatically trigger rebuilds
/// items.add('d');
/// ```
///
/// ## Notification Behavior
///
/// Methods only call [ChangeNotifier.notifyListeners] when the collection
/// actually changes. For example:
///
/// - `set.add(existingElement)` - No notification (element already exists)
/// - `map['key'] = sameValue` - No notification (value unchanged)
/// - `list.clear()` on empty list - No notification (nothing to clear)
///
/// This optimization prevents unnecessary widget rebuilds.
library;

import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart' show ValueListenableBuilder;
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:flutter/material.dart' show ValueListenableBuilder;
import 'package:flutter/widgets.dart' show ValueListenableBuilder;

part 'src/list_notifier.dart';
part 'src/map_notifier.dart';
part 'src/queue_notifier.dart';
part 'src/set_notifier.dart';
