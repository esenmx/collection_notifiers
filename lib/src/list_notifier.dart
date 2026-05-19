part of '../collection_notifiers.dart';

/// A [List] implementation that notifies listeners when modified.
///
/// Extends [DelegatingList] and mixes in [ChangeNotifier] to provide
/// reactive list updates compatible with [ValueListenableBuilder] and
/// state management solutions like Riverpod and Provider.
///
/// {@template collection_notifiers.notification_behavior}
/// ## Notification Behavior
///
/// Methods only call [notifyListeners] when the collection actually changes.
/// This prevents unnecessary widget rebuilds.
/// {@endtemplate}
///
/// ## Example
///
/// ```dart
/// final todos = ListNotifier<String>(['Buy milk', 'Walk dog']);
///
/// // Listen to changes
/// todos.addListener(() => print('List changed: $todos'));
///
/// todos.add('Call mom');      // Notifies: [Buy milk, Walk dog, Call mom]
/// todos.removeAt(0);          // Notifies: [Walk dog, Call mom]
/// todos[0] = 'Walk dog';      // No notification (value unchanged)
/// todos[0] = 'Feed dog';      // Notifies: [Feed dog, Call mom]
/// ```
class ListNotifier<E> extends DelegatingList<E>
    with ChangeNotifier
    implements ValueListenable<List<E>> {
  /// Creates a [ListNotifier] optionally initialized with [base] elements.
  ///
  /// The [base] iterable is copied, so changes to the original do not affect
  /// this notifier.
  ListNotifier([Iterable<E> base = const []]) : super(List<E>.of(base));

  /// Returns this list as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
  @override
  List<E> get value => this;

  @override
  set length(int newLength) {
    if (newLength == super.length) {
      return;
    }
    super.length = newLength;
    notifyListeners();
  }

  @override
  set first(E value) {
    if (super.isEmpty) {
      throw StateError('No element');
    }
    if (super.first != value) {
      super[0] = value;
      notifyListeners();
    }
  }

  @override
  set last(E value) {
    if (super.isEmpty) {
      throw StateError('No element');
    }
    if (super.last != value) {
      super[super.length - 1] = value;
      notifyListeners();
    }
  }

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
    RangeError.checkValidRange(start, end, length);
    if (start == end) {
      return;
    }
    final value = fillValue as E;
    var shouldNotify = false;
    for (var i = start; i < end; i++) {
      if (!shouldNotify && super[i] != value) {
        shouldNotify = true;
      }
      super[i] = value;
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
    if (end != start || iterable.isNotEmpty) {
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
    if (end != start) {
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
