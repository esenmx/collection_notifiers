part of collection_notifiers;

class MapNotifier<K, V> extends DelegatingMap<K, V>
    with ChangeNotifier
    implements ValueListenable<Map<K, V>> {
  MapNotifier(Map<K, V> base) : super(base);

  @override
  void operator []=(K key, V value) {
    if (this[key] != value) {
      this[key] = value;
      notifyListeners();
    }
  }

  @override
  Map<K, V> get value => this;

  @override
  void addAll(Map<K, V> other) {
    addEntries(other.entries);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    bool hasChanged = false;
    for (final entry in entries) {
      hasChanged = hasChanged || this[entry.key] != entry.value;
      this[entry.key] = entry.value;
    }
    if (hasChanged) {
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
    final value = super.remove(key);
    if (value != null) {
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
    final value = this[key];
    final newValue = super.update(key, update, ifAbsent: ifAbsent);
    if (value != newValue) {
      notifyListeners();
    }
    return newValue;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    bool hasChanged = false;
    for (final entry in super.entries) {
      final newValue = update(entry.key, entry.value);
      hasChanged = hasChanged || newValue != entry.value;
      this[entry.key] = newValue;
    }
    if (hasChanged) {
      notifyListeners();
    }
  }
}
