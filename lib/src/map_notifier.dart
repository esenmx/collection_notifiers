part of '../collection_notifiers.dart';

/// A [Map] implementation that notifies listeners when modified.
///
/// Extends [DelegatingMap] and mixes in [ChangeNotifier] to provide
/// reactive map updates compatible with [ValueListenableBuilder] and
/// state management solutions like Riverpod and Provider.
///
/// {@macro collection_notifiers.notification_behavior}
///
/// ## Example
///
/// ```dart
/// final settings = MapNotifier<String, bool>({'darkMode': false});
///
/// // Listen to changes
/// settings.addListener(() => print('Settings changed: $settings'));
///
/// settings['darkMode'] = true;   // Notifies: {darkMode: true}
/// settings['darkMode'] = true;   // No notification (value unchanged)
/// settings['sound'] = true;      // Notifies: {darkMode: true, sound: true}
/// settings.remove('sound');      // Notifies: {darkMode: true}
/// ```
class MapNotifier<K, V> extends DelegatingMap<K, V>
    with ChangeNotifier
    implements ValueListenable<Map<K, V>> {
  /// Creates a [MapNotifier] optionally initialized with [base] entries.
  ///
  /// The [base] map is copied, so changes to the original do not affect
  /// this notifier.
  MapNotifier([Map<K, V> base = const {}]) : super(Map<K, V>.of(base));

  /// Returns this map as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
  @override
  Map<K, V> get value => this;

  @override
  void operator []=(K key, V value) {
    if (!super.containsKey(key) || super[key] != value) {
      super[key] = value;
      notifyListeners();
    } else {
      super[key] = value;
    }
  }

  @override
  void addAll(Map<K, V> other) {
    var shouldUpdate = false;
    for (final entry in other.entries) {
      if (!shouldUpdate && super[entry.key] != entry.value) {
        shouldUpdate = true;
      }
      super[entry.key] = entry.value;
    }
    if (shouldUpdate) {
      notifyListeners();
    }
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    final length = super.length;
    super.addEntries(entries);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  void clear() {
    if (isNotEmpty) {
      super.clear();
      notifyListeners();
    }
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    if (!super.containsKey(key)) {
      super.putIfAbsent(key, ifAbsent);
      notifyListeners();
    }
    return super[key]!;
  }

  @override
  V? remove(Object? key) {
    if (super.containsKey(key)) {
      final value = super.remove(key);
      notifyListeners();
      return value;
    }
    return null;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    final length = super.length;
    super.removeWhere(test);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final value = super[key];
    final newValue = super.update(key, update, ifAbsent: ifAbsent);
    if (value != newValue) {
      notifyListeners();
    }
    return newValue;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    var shouldNotify = false;
    for (final entry in super.entries) {
      final newValue = update(entry.key, entry.value);
      shouldNotify = shouldNotify || newValue != entry.value;
      super[entry.key] = newValue;
    }
    if (shouldNotify) {
      notifyListeners();
    }
  }
}
