import 'package:flutter/foundation.dart';

class MatchProvider extends ChangeNotifier {
  bool loading = false;
  String? error;
  void clearError() { error = null; notifyListeners(); }
}
