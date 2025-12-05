import 'package:mockito/mockito.dart';

class VoidListener extends Mock {
  void call();

  void called(int count) => verify(call()).called(count);

  void get verifyNotCalled => verifyNever(call());

  void get verifyCalledOnce => called(1);

  void get verifyCalledTwice => called(2);

  void get verifyCalledThrice => called(3);
}
