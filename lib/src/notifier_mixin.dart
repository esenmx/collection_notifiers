part of '../collection_notifiers.dart';

mixin _NotifierMixin on ChangeNotifier {
  int _batchDepth = 0;
  int _notificationDepth = 0;
  bool _batchDirty = false;
  bool _disposed = false;

  int get length;

  /// Runs [body] and notifies listeners at most once, after [body]
  /// returns or throws, if any mutation inside it would have notified.
  ///
  /// Nested calls coalesce into the outermost one.
  ///
  /// [body] must be synchronous: changes made after an `await` cannot be
  /// coalesced. A [body] whose type returns a [Future] (an `async`
  /// closure) throws [ArgumentError] before it runs. A [body] typed
  /// otherwise that returns a [Future] at runtime throws [ArgumentError]
  /// after it returns; changes it made before its first `await` are
  /// notified once first, as for a [body] that throws.
  void batch(void Function() body) {
    _checkNotDisposed();
    if (body is Future<Object?> Function() && body is! Never Function()) {
      throw ArgumentError.value(body, 'body', 'must be synchronous');
    }
    _batchDepth++;
    final Object? result;
    try {
      result = body() as dynamic;
    } finally {
      _batchDepth--;
      if (_batchDepth == 0 && _batchDirty) {
        _batchDirty = false;
        if (!_disposed) {
          _dispatch();
        }
      }
    }
    if (result is Future<Object?>) {
      throw ArgumentError.value(body, 'body', 'must be synchronous');
    }
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('$runtimeType used after dispose()');
    }
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
  void addListener(VoidCallback listener) {
    _checkNotDisposed();
    super.addListener(listener);
  }

  @override
  void notifyListeners() {
    _checkNotDisposed();
    if (_batchDepth > 0) {
      _batchDirty = true;
      return;
    }
    _dispatch();
  }

  void _dispatch() {
    _notificationDepth++;
    try {
      super.notifyListeners();
    } finally {
      _notificationDepth--;
    }
  }

  /// Throws [StateError] during a notification, leaving the notifier alive.
  /// From a listener, [ChangeNotifier] reports it through
  /// `FlutterError.onError`, like anything else a listener throws, and the
  /// mutation that notified returns normally.
  @override
  void dispose() {
    _checkNotDisposed();
    if (_notificationDepth > 0) {
      throw StateError('$runtimeType disposed during a notification');
    }
    _disposed = true;
    _batchDirty = false;
    super.dispose();
  }
}
