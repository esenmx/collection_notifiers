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
class SetNotifier<E> extends DelegatingSet<E>
    with ChangeNotifier
    implements ValueListenable<Set<E>> {
  /// Creates a [SetNotifier] optionally initialized with [base] elements.
  ///
  /// The [base] iterable is copied, so changes to the original do not affect
  /// this notifier.
  SetNotifier([Iterable<E> base = const []]) : super(Set<E>.of(base));

  /// Returns this set as the listenable value.
  ///
  /// Implements [ValueListenable.value] by returning `this`, allowing
  /// direct use with [ValueListenableBuilder].
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
}
