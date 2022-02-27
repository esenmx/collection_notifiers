part of collection_notifiers;

class MapNotifier<K, V> extends DelegatingMap<K, V>
    with ChangeNotifier
    implements ValueListenable<Map<K, V>> {
  MapNotifier([Map<K, V> base = const {}]) : super(Map<K, V>.of(base));

  @override
  Map<K, V> get value => this;

  @override
  void operator []=(K key, V value) {
    if (!super.containsKey(key) || super[key] != value) {
      super[key] = value;
      notifyListeners();
    }
  }

  @override
  void addAll(Map<K, V> other) {
    final length = super.length;
    super.addAll(other);
    if (length != super.length) {
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
    bool shouldNotify = false;
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
