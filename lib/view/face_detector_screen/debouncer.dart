import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    print("action is called");
    _timer?.cancel(); // Cancel the previous timer if it exists
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}