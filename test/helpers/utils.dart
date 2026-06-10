import 'package:checks/checks.dart';

/// Callable listener that counts invocations. Plug into any
/// `Listenable.addListener`.
///
/// ```dart
/// final listener = VoidListener();
/// notifier
///   ..addListener(listener)
///   ..add(1);
/// listener.verifyCalledOnce;
/// ```
class VoidListener {
  int callCount = 0;

  void call() {
    callCount++;
  }

  /// Verifies the listener was invoked [count] times since the last
  /// verification, then resets the counter — same semantics as
  /// mockito's `verify(call()).called(count)`.
  void called(int count) {
    check(callCount).equals(count);
    callCount = 0;
  }

  void get verifyNotCalled => called(0);

  void get verifyCalledOnce => called(1);

  void get verifyCalledTwice => called(2);

  void get verifyCalledThrice => called(3);
}
