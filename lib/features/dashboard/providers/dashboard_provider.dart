import 'package:flutter/foundation.dart';

class DashboardProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  void clearError() {
    error = null;
    notifyListeners();
  }
}
