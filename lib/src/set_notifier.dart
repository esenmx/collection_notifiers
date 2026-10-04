part of '../collection_notifiers.dart';

/// A [Set] implementation that notifies listeners when modified.
///
/// Extends [DelegatingSet] and mixes in [ChangeNotifier] to provide
/// reactive set updates compatible with [ValueListenableBuilder] and
/// state management solutions like Riverpod and Provider.
///
/// {@macro collection_notifiers.notification_behavior}
///
/// ## Example
///
/// ```dart
/// final selectedIds = SetNotifier<int>();
///
/// // Listen to changes
/// selectedIds.addListener(() => print('Selection: $selectedIds'));
///
/// selectedIds.add(1);        // Notifies: {1}
/// selectedIds.add(2);        // Notifies: {1, 2}
/// selectedIds.add(1);        // No notification (already exists)
/// selectedIds.remove(1);     // Notifies: {2}
/// selectedIds.invert(2);     // Notifies: {} (toggles off)
/// selectedIds.invert(3);     // Notifies: {3} (toggles on)
/// ```
class SetNotifier<E>([Iterable<E> base = const []])
    extends DelegatingSet<E>
    with ChangeNotifier, _NotifierMixin
    implements ValueListenable<Set<E>> {
  /// Creates a [SetNotifier] optionally initialized with [base] elements.
  ///
  /// [base] is copied **shallowly**. Changes to the source iterable's
  /// membership do not affect this notifier, but element references are
  /// shared — mutating an element in place will bypass the "no-rebuild
  /// on no-op" check because the element's identity didn't change. Use
  /// `freezed` / `equatable` or otherwise immutable element types for
  /// reliable smart-notification.
  this : super(Set<E>.of(base)) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  /// Returns this set as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
  @override
  Set<E> get value => this;

  @override
  bool add(E value) {
    _debugAssertNotDisposed();
    if (super.add(value)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void addAll(Iterable<E> elements) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.addAll(elements));
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
  bool remove(Object? value) {
    _debugAssertNotDisposed();
    if (super.remove(value)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.removeAll(elements));
  }

  @override
  void removeWhere(bool Function(E e) test) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.removeWhere(test));
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.retainAll(elements));
  }

  @override
  void retainWhere(bool Function(E e) test) {
    _debugAssertNotDisposed();
    _notifyOnLengthChange(() => super.retainWhere(test));
  }

  /// Toggles an element's presence in the set.
  ///
  /// If [element] exists, removes it and returns `false`.
  /// If [element] does not exist, adds it and returns `true`.
  ///
  /// This is useful for checkbox-like UI patterns:
  ///
  /// ```dart
  /// final selected = SetNotifier<int>();
  ///
  /// CheckboxListTile(
  ///   value: selected.contains(itemId),
  ///   onChanged: (_) => selected.invert(itemId),
  /// )
  /// ```
  ///
  /// Returns `true` if the element was added, `false` if removed.
  bool invert(E element) {
    if (contains(element)) {
      remove(element);
      return false;
    }
    add(element);
    return true;
  }

  @override
  Set<R> cast<R>() => Set.castFrom<E, R>(this);

  /// Replaces the contents with [elements], notifying once only when the
  /// resulting sequence differs by `==`.
  void assignAll(Iterable<E> elements) {
    _debugAssertNotDisposed();
    final next = List<E>.of(elements);
    final before = List<E>.of(this);
    super.clear();
    super.addAll(next);
    if (!const IterableEquality<Object?>().equals(before, this)) {
      notifyListeners();
    }
  }
}
