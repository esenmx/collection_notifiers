part of '../collection_notifiers.dart';

mixin _NotifierMixin on ChangeNotifier {
  int get length;

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
}
