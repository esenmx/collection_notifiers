import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ListNotifier<E> extends DelegatingList<E>
    with ChangeNotifier
    implements List<E> {
  ListNotifier([Iterable<E> elements = const []]) : super(List<E>.of(elements));

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
    if (super[index] != element) {
      super.insert(index, element);
      notifyListeners();
    }
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
    super.removeRange(start, end);
    notifyListeners();
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
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(E p1) test) {
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
    super.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void shuffle([math.Random? random]) {
    super.shuffle(random);
    notifyListeners();
  }

  @override
  void sort([int Function(E p1, E p2)? compare]) {
    super.sort(compare);
    notifyListeners();
  }
}
