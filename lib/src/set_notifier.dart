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
    final length = super.length;
    super.addAll(elements);
    if (length != super.length) {
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
    final length = super.length;
    super.removeAll(elements);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  void removeWhere(bool Function(E e) test) {
    final length = super.length;
    super.removeWhere(test);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    final length = super.length;
    super.retainAll(elements);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  void retainWhere(bool Function(E e) test) {
    final length = super.length;
    super.retainWhere(test);
    if (length != super.length) {
      notifyListeners();
    }
  }

  ///
  /// Extras
  ///

  // Removes if value exists, add if not. Useful for checkbox like widgets
  bool invert(E element) {
    if (contains(element)) {
      return remove(element);
    }
    return add(element);
  }
}
