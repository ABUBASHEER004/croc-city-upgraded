import 'package:cloud_functions/cloud_functions.dart';

class AdminService {
  AdminService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final result =
        await _functions.httpsCallable('adminCreateManagedUser').call({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim().toLowerCase(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
      'role': role,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<Map<String, dynamic>> resetUserPassword({
    required String uid,
    String? newPassword,
  }) async {
    final result = await _functions
        .httpsCallable('adminResetManagedUserPassword')
        .call({
      'uid': uid,
      if (newPassword != null && newPassword.trim().isNotEmpty)
        'newPassword': newPassword.trim(),
    });

    return Map<String, dynamic>.from(result.data as Map);
  }
}