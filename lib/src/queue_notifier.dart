part of collection_notifiers;

class QueueNotifier<E> extends DelegatingQueue<E>
    with ChangeNotifier
    implements ValueListenable<Queue<E>> {
  QueueNotifier([Iterable<E> base = const []]) : super(Queue<E>.of(base));

  @override
  Queue<E> get value => this;

  @override
  void addAll(Iterable<E> iterable) {
    // TODO: implement addAll
    super.addAll(iterable);
  }

  @override
  void addFirst(E value) {
    // TODO: implement addFirst
    super.addFirst(value);
  }

  @override
  void addLast(E value) {
    // TODO: implement addLast
    super.addLast(value);
  }

  @override
  void clear() {
    // TODO: implement clear
    super.clear();
  }

  @override
  bool remove(Object? object) {
    // TODO: implement remove
    return super.remove(object);
  }

  @override
  E removeFirst() {
    // TODO: implement removeFirst
    return super.removeFirst();
  }

  @override
  E removeLast() {
    // TODO: implement removeLast
    return super.removeLast();
  }

  @override
  void removeWhere(bool Function(E p1) test) {
    // TODO: implement removeWhere
    super.removeWhere(test);
  }

  @override
  void retainWhere(bool Function(E p1) test) {
    // TODO: implement retainWhere
    super.retainWhere(test);
  }
}
