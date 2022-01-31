part of collection_notifiers;

class ListNotifier<E> extends DelegatingList<E>
    with ChangeNotifier
    implements ValueListenable<List<E>> {
  ListNotifier([Iterable<E> elements = const []]) : super(List<E>.of(elements));

  @override
  List<E> get value => this;

  @override
  void operator []=(int index, E value) {
    if (super[index] != value) {
      super[index] = value;
      notifyListeners();
    }
  }

  @override
  void add(E value) {
    super.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    if (iterable.isNotEmpty) {
      super.addAll(iterable);
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
  void fillRange(int start, int end, [E? fillValue]) {
    if (start != end) {
      super.fillRange(start, end, fillValue);
      notifyListeners();
    }
  }

  @override
  void insert(int index, E element) {
    super.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    if (iterable.isNotEmpty) {
      super.insertAll(index, iterable);
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
  E removeAt(int index) {
    final removed = super.removeAt(index);
    notifyListeners();
    return removed;
  }

  @override
  void removeRange(int start, int end) {
    if (end != start) {
      super.removeRange(start, end);
      notifyListeners();
    }
  }

  @override
  E removeLast() {
    final last = super.removeLast();
    notifyListeners();
    return last;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    final length = super.length;
    super.removeWhere(test);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    if (end != start) {
      super.replaceRange(start, end, iterable);
      notifyListeners();
    }
  }

  @override
  void retainWhere(bool Function(E element) test) {
    final length = super.length;
    super.retainWhere(test);
    if (length != super.length) {
      notifyListeners();
    }
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    super.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    if (end != start) {
      super.setRange(start, end, iterable, skipCount);
      notifyListeners();
    }
  }

  @override
  void shuffle([math.Random? random]) {
    super.shuffle(random);
    notifyListeners();
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    super.sort(compare);
    notifyListeners();
  }
}
