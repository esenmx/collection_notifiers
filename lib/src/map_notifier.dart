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
class MapNotifier<K, V>([Map<K, V> base = const {}])
    extends DelegatingMap<K, V>
    with ChangeNotifier, _NotifierMixin
    implements ValueListenable<Map<K, V>> {
  /// Creates a [MapNotifier] optionally initialized with [base] entries.
  ///
  /// [base] is copied **shallowly**. Changes to the source map's entries
  /// do not affect this notifier, but key and value references are
  /// shared — mutating a value in place will bypass the "no-rebuild on
  /// no-op" check because the value's identity didn't change. Use
  /// `freezed` / `equatable` or otherwise immutable value types for
  /// reliable smart-notification.
  this : super(Map<K, V>.of(base));

  /// Returns this map as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
  @override
  Map<K, V> get value => this;

  @override
  void operator []=(K key, V value) {
    _debugAssertNotDisposed();
    final changed = !super.containsKey(key) || super[key] != value;
    super[key] = value;
    if (changed) {
      notifyListeners();
    }
  }

  @override
  void addAll(Map<K, V> other) => addEntries(other.entries);

  /// Adds [entries] and notifies when the map changes.
  ///
  /// This method checks if any entry contains a new key or a modified value,
  /// notifying listeners if a change is found.
  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    _debugAssertNotDisposed();
    var changed = false;
    try {
      for (final MapEntry(:key, :value) in entries) {
        changed = changed || !super.containsKey(key) || super[key] != value;
        super[key] = value;
      }
    } finally {
      if (changed) {
        notifyListeners();
      }
    }
  }

  @override
  void clear() {
    _debugAssertNotDisposed();
    if (isNotEmpty) {
      super.clear();
      notifyListeners();
    }
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    _debugAssertNotDisposed();
    final hadKey = super.containsKey(key);
    final value = super.putIfAbsent(key, ifAbsent);
    if (!hadKey) {
      notifyListeners();
    }
    return value;
  }

  @override
  V? remove(Object? key) {
    _debugAssertNotDisposed();
    if (super.containsKey(key)) {
      final value = super.remove(key);
      notifyListeners();
      return value;
    }
    return null;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.removeWhere(test));
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    _debugAssertNotDisposed();
    final hadKey = super.containsKey(key);
    final value = super[key];
    final newValue = super.update(key, update, ifAbsent: ifAbsent);
    if (!hadKey || value != newValue) {
      notifyListeners();
    }
    return newValue;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    _debugAssertNotDisposed();
    var shouldNotify = false;
    try {
      for (final entry in super.entries) {
        final newValue = update(entry.key, entry.value);
        shouldNotify = shouldNotify || newValue != entry.value;
        super[entry.key] = newValue;
      }
    } finally {
      if (shouldNotify) {
        notifyListeners();
      }
    }
  }

  @override
  Map<RK, RV> cast<RK, RV>() => Map.castFrom<K, V, RK, RV>(this);

  @override
  void notifyListeners() => super.notifyListeners();
}
