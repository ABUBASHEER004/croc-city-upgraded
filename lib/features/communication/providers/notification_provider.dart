import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  void clearError() {
    error = null;
    notifyListeners();
  }
}
