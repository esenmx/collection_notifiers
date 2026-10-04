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
class QueueNotifier<E>([Iterable<E> base = const []])
    extends DelegatingQueue<E>
    with ChangeNotifier, _NotifierMixin
    implements ValueListenable<Queue<E>> {
  /// Creates a [QueueNotifier] optionally initialized with [base] elements.
  ///
  /// [base] is copied **shallowly**. Changes to the source iterable do
  /// not affect this notifier, but element references are shared —
  /// mutating an element in place will bypass the "no-rebuild on no-op"
  /// check because the element's identity didn't change. Use `freezed`
  /// / `equatable` or otherwise immutable element types for reliable
  /// smart-notification.
  this : super(Queue<E>.of(base));

  /// Returns this queue as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
  @override
  Queue<E> get value => this;

  @override
  void add(E value) {
    _debugAssertNotDisposed();
    super.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.addAll(iterable));
  }

  @override
  void addFirst(E value) {
    _debugAssertNotDisposed();
    super.addFirst(value);
    notifyListeners();
  }

  @override
  void addLast(E value) {
    _debugAssertNotDisposed();
    super.addLast(value);
    notifyListeners();
  }

  @override
  void clear() {
    _debugAssertNotDisposed();
    if (super.isNotEmpty) {
      super.clear();
      notifyListeners();
    }
  }

  @override
  bool remove(Object? object) {
    _debugAssertNotDisposed();
    if (super.remove(object)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  E removeFirst() {
    _debugAssertNotDisposed();
    final element = super.removeFirst();
    notifyListeners();
    return element;
  }

  @override
  E removeLast() {
    _debugAssertNotDisposed();
    final element = super.removeLast();
    notifyListeners();
    return element;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.removeWhere(test));
  }

  @override
  void retainWhere(bool Function(E element) test) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.retainWhere(test));
  }

  @override
  Queue<R> cast<R>() => Queue.castFrom<E, R>(this);

  @override
  void notifyListeners() => super.notifyListeners();
}
