import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/app_user.dart';

class ParentRepository {
  ParentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AppUser>> watchParents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Parent')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['uid'] = data['uid'] ?? doc.id;
                return AppUser.fromMap(data);
              })
              .toList(),
        );
  }

  Future<AppUser?> getParent(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap({...doc.data()!, 'uid': uid});
  }
}
