import 'package:flutter/material.dart';

class AutoPlayNotifier {
  static int _value = 0;
  static AutoPlayNotifier _notifier;
  ValueNotifier<int> nextVideoIndex = ValueNotifier<int>(_value);

  AutoPlayNotifier._internal();

  factory AutoPlayNotifier() {
    if (_notifier == null) _notifier = AutoPlayNotifier._internal();
    return _notifier;
  }

  void completed(int index) {
    if (index == null) return;
    _value = index + 1;
    nextVideoIndex.value = _value;
  }

  void setIndex(int index) {
    if (index == null) return;
    _value = index;
    nextVideoIndex.value = _value;
  }
}
