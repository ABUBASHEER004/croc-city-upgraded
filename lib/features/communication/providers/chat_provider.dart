import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  void clearError() {
    error = null;
    notifyListeners();
  }
}
