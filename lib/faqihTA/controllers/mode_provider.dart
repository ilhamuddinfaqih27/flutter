import 'package:flutter/material.dart';

class ModeProvider extends ChangeNotifier {
  bool isManual = true;

  void toggleMode() {
    isManual = !isManual;
    notifyListeners();
  }
}
