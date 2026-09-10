import 'package:flutter/foundation.dart';

class AnnouncementProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  void clearError() {
    error = null;
    notifyListeners();
  }
}
