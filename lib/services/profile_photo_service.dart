import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Centralized profile-photo upload service.
///
/// Uses XFile bytes instead of dart:io so the same code works on
/// Android, iOS, web and desktop targets supported by Flutter.
class ProfilePhotoService {
  ProfilePhotoService._();

  static final ProfilePhotoService instance = ProfilePhotoService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadUserPhoto({
    required String uid,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('The selected image is empty.');
    }

    final extension = _extension(file.name);
    final ref = _storage.ref('profile_photos/users/$uid.$extension');

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: _contentType(extension),
        cacheControl: 'public,max-age=86400',
      ),
    );

    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).set(
      {
        'photoUrl': url,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return url;
  }

  Future<String> uploadPlayerPhoto({
    required String playerId,
    required XFile file,
  }) async {
    return _uploadCollectionPhoto(
      collection: 'players',
      id: playerId,
      file: file,
    );
  }

  Future<String> uploadCoachPhoto({
    required String coachId,
    required XFile file,
  }) async {
    return _uploadCollectionPhoto(
      collection: 'coaches',
      id: coachId,
      file: file,
    );
  }

  Future<String> _uploadCollectionPhoto({
    required String collection,
    required String id,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('The selected image is empty.');
    }

    final extension = _extension(file.name);
    final ref = _storage.ref(
      'profile_photos/$collection/$id.$extension',
    );

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: _contentType(extension),
        cacheControl: 'public,max-age=86400',
      ),
    );

    final url = await ref.getDownloadURL();

    await _firestore.collection(collection).doc(id).set(
      {
        'photoUrl': url,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return url;
  }

  Future<void> deleteUserPhoto(String uid) async {
    final ref = _storage.ref('profile_photos/users/$uid');
    try {
      await ref.delete();
    } catch (_) {
      // Deleting an already-missing image is harmless.
    }

    await _firestore.collection('users').doc(uid).set(
      {
        'photoUrl': null,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  String _extension(String name) {
    final clean = name.toLowerCase().split('?').first;
    final dot = clean.lastIndexOf('.');
    final ext = dot == -1 ? 'jpg' : clean.substring(dot + 1);

    return switch (ext) {
      'jpeg' => 'jpg',
      'png' => 'png',
      'webp' => 'webp',
      'gif' => 'gif',
      _ => 'jpg',
    };
  }

  String _contentType(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}
