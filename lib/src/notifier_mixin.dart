part of '../collection_notifiers.dart';

mixin _NotifierMixin on ChangeNotifier {
  int _batchDepth = 0;
  bool _batchDirty = false;

  int get length;

  /// Runs [body] and notifies listeners at most once, after [body]
  /// returns or throws, if any mutation inside it would have notified.
  ///
  /// Nested calls coalesce into the outermost one. [body] must be
  /// synchronous.
  void batch(void Function() body) {
    _debugAssertNotDisposed();
    _batchDepth++;
    try {
      final Object? result = body() as dynamic;
      assert(result is! Future<Object?>, 'batch() body must be synchronous.');
    } finally {
      _batchDepth--;
      if (_batchDepth == 0 && _batchDirty) {
        _batchDirty = false;
        super.notifyListeners();
      }
    }
  }

  void _debugAssertNotDisposed() {
    assert(ChangeNotifier.debugAssertNotDisposed(this), 'Used after dispose.');
  }

  void _notifyOnLengthChange(void Function() mutate) {
    final before = length;
    try {
      mutate();
    } finally {
      if (length != before) {
        notifyListeners();
      }
    }
  }

  @override
  void notifyListeners() {
    if (_batchDepth > 0) {
      _batchDirty = true;
      return;
    }
    super.notifyListeners();
  }
}
