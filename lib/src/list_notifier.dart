part of collection_notifiers;

class ListNotifier<E> extends DelegatingList<E>
    with ChangeNotifier
    implements ValueListenable<List<E>> {
  ListNotifier([Iterable<E> base = const []]) : super(List<E>.of(base));

  @override
  List<E> get value => this;

  @override
  void operator []=(int index, E value) {
    if (super[index] != value) {
      super[index] = value;
      notifyListeners();
    } else {
      super[index] = value;
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
    final E nonNullFillValue = fillValue as E;
    RangeError.checkValidRange(start, end, length);
    bool shouldNotify = false;
    for (int i = start; i < end; i++) {
      shouldNotify = shouldNotify || super[i] != fillValue;
      super[i] = nonNullFillValue;
    }
    if (shouldNotify) {
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
    super.insertAll(index, iterable);
    if (iterable.isNotEmpty) {
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
    final length = super.length;
    super.removeRange(start, end);
    if (length != super.length) {
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
    super.replaceRange(start, end, iterable);
    if (end != start && iterable.isNotEmpty) {
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
    if (iterable.isNotEmpty) {
      notifyListeners();
    }
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    super.setRange(start, end, iterable, skipCount);
    if (end != start && iterable.isNotEmpty) {
      notifyListeners();
    }
  }

  @override
  void shuffle([math.Random? random]) {
    if (length > 1) {
      super.shuffle(random);
      notifyListeners();
    }
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    if (length > 1) {
      super.sort(compare);
      notifyListeners();
    }
  }
}
