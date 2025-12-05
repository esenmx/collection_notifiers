part of '../collection_notifiers.dart';

/// A [Queue] implementation that notifies listeners when modified.
///
/// Extends [DelegatingQueue] and mixes in [ChangeNotifier] to provide
/// reactive queue updates compatible with [ValueListenableBuilder] and
/// state management solutions like Riverpod and Provider.
///
/// {@macro collection_notifiers.notification_behavior}
///
/// ## Example
///
/// ```dart
/// final tasks = QueueNotifier<String>();
///
/// // Listen to changes
/// tasks.addListener(() => print('Queue: $tasks'));
///
/// tasks.addLast('Task 1');   // Notifies: [Task 1]
/// tasks.addLast('Task 2');   // Notifies: [Task 1, Task 2]
/// tasks.addFirst('Urgent');  // Notifies: [Urgent, Task 1, Task 2]
/// tasks.removeFirst();       // Notifies: [Task 1, Task 2]
/// ```
class QueueNotifier<E> extends DelegatingQueue<E>
    with ChangeNotifier
    implements ValueListenable<Queue<E>> {
  /// Creates a [QueueNotifier] optionally initialized with [base] elements.
  ///
  /// The [base] iterable is copied, so changes to the original do not affect
  /// this notifier.
  QueueNotifier([Iterable<E> base = const []]) : super(Queue<E>.of(base));

  /// Returns this queue as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
  @override
  Queue<E> get value => this;

  @override
  void add(E value) {
    super.add(value);
    notifyListeners();
  }

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
