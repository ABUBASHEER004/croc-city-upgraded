import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../models/app_user.dart';
import '../../data/parent_repository.dart';

class ParentProvider extends ChangeNotifier {
  ParentProvider(this._repository);

  final ParentRepository _repository;
  StreamSubscription<List<AppUser>>? _subscription;

  List<AppUser> parents = [];
  bool loading = false;
  String? error;

  void listenToParents() {
    loading = true;
    error = null;
    notifyListeners();
    _subscription?.cancel();

    _subscription = _repository.watchParents().listen(
      (value) {
        parents = value;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
        notifyListeners();
      },
    );
  }

  Future<AppUser?> getParent(String uid) => _repository.getParent(uid);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
