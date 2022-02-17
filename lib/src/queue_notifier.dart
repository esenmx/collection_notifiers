part of collection_notifiers;

class QueueNotifier<E> extends DelegatingQueue<E>
    with ChangeNotifier
    implements ValueListenable<Queue<E>> {
  QueueNotifier([Iterable<E> base = const []]) : super(Queue<E>.of(base));

  @override
  Queue<E> get value => this;

  @override
  void addAll(Iterable<E> iterable) {
    super.addAll(iterable);
    if (iterable.isNotEmpty) {
      notifyListeners();
    }
  }

  @override
  void addFirst(E value) {
    super.addFirst(value);
    notifyListeners();
  }

  @override
  void addLast(E value) {
    super.addLast(value);
    notifyListeners();
  }

  @override
  void clear() {
    if (super.isNotEmpty) {
      super.clear();
      notifyListeners();
    }
  }

  @override
  bool remove(Object? object) {
    if (super.remove(object)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  E removeFirst() {
    final element = super.removeFirst();
    notifyListeners();
    return element;
  }

  @override
  E removeLast() {
    final element = super.removeLast();
    notifyListeners();
    return element;
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
  void retainWhere(bool Function(E element) test) {
    final length = super.length;
    super.retainWhere(test);
    if (length != super.length) {
      notifyListeners();
    }
  }
}
