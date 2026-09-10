import 'package:flutter/foundation.dart';
import '../data/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  FinanceProvider({FinanceRepository? repository}) : repository = repository ?? FinanceRepository();
  final FinanceRepository repository;
  bool loading = false;
  String? error;

  void clearError() {
    error = null;
    notifyListeners();
  }
}
