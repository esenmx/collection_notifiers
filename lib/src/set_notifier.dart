part of collection_notifiers;

class SetNotifier<E> extends DelegatingSet<E>
    with ChangeNotifier
    implements ValueListenable<Set<E>> {
  SetNotifier([Iterable<E> base = const []]) : super(Set<E>.of(base));

  @override
  Set<E> get value => this;

  @override
  bool add(E value) {
    if (super.add(value)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void addAll(Iterable<E> elements) {
    bool hasChanged = false;
    for (final e in elements) {
      hasChanged = super.add(e) || hasChanged;
    }
    if (hasChanged) {
      notifyListeners();
    }
  }

  @override
  void clear() {
    if (super.isNotEmpty) {
      super.clear();
      notifyListeners();
    }
  }

  @override
  bool remove(Object? value) {
    if (super.remove(value)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    bool hasChanged = false;
    for (final e in elements) {
      hasChanged = super.remove(e) || hasChanged;
    }
    if (hasChanged) {
      notifyListeners();
    }
  }

  @override
  void removeWhere(bool Function(E e) test) {
    /// Avoiding [LazyIterable] for preventing [ConcurrentModificationError]
    final toRemove = where((e) => test(e)).toList();
    removeAll(toRemove);
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    /// Converting to [Set] for constant [contains] operations
    final toRetain = elements.toSet();
    removeWhere((e) => !toRetain.contains(e));
  }

  @override
  void retainWhere(bool Function(E e) test) {
    removeWhere((e) => !test(e));
  }
}
