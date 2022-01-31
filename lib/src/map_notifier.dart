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
  // TODO: implement value
  Map<K, V> get value => throw UnimplementedError();

  @override
  void addAll(Map<K, V> other) {
    // TODO: implement addAll
    super.addAll(other);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    // TODO: implement addEntries
    super.addEntries(entries);
  }

  @override
  void clear() {
    // TODO: implement clear
    super.clear();
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    // TODO: implement putIfAbsent
    return super.putIfAbsent(key, ifAbsent);
  }

  @override
  V? remove(Object? key) {
    // TODO: implement remove
    return super.remove(key);
  }

  @override
  void removeWhere(bool Function(K p1, V p2) test) {
    // TODO: implement removeWhere
    super.removeWhere(test);
  }

  @override
  V update(K key, V Function(V p1) update, {V Function()? ifAbsent}) {
    // TODO: implement update
    return super.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(V Function(K p1, V p2) update) {
    // TODO: implement updateAll
    super.updateAll(update);
  }
}
