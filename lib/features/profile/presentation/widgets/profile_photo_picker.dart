
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoPicker extends StatefulWidget {
  const ProfilePhotoPicker({
    super.key,
    this.photoUrl,
    required this.onImageSelected,
    this.busy = false,
    this.radius = 58,
    this.label = 'Change photo',
  });

  final String? photoUrl;
  final ValueChanged<XFile> onImageSelected;
  final bool busy;
  final double radius;
  final String label;

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  Uint8List? _imageBytes;
  bool _loadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  @override
  void didUpdateWidget(covariant ProfilePhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.photoUrl != widget.photoUrl) {
      _imageBytes = null;
      _loadPhoto();
    }
  }

  Future<void> _loadPhoto() async {
    final url = widget.photoUrl;

    if (url == null || url.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _imageBytes = null;
          _loadingImage = false;
        });
      }
      return;
    }

    setState(() {
      _loadingImage = true;
    });

    try {
      final storage = FirebaseStorage.instance;

      // Extract the Storage object path from the Firebase download URL.
      final uri = Uri.tryParse(url);

      if (uri == null) {
        throw Exception('Invalid profile photo URL.');
      }

      String? objectPath;

      final pathMatch = RegExp(
        r'/o/(.+?)(?:\?|$)',
      ).firstMatch(uri.toString());

      if (pathMatch != null) {
        objectPath = Uri.decodeComponent(pathMatch.group(1)!);
      }

      if (objectPath == null || objectPath.isEmpty) {
        throw Exception('Could not determine Storage object path.');
      }

      debugPrint(
        'PROFILE PHOTO LOAD: downloading Storage object: $objectPath',
      );

      final ref = storage.ref().child(objectPath);

      // 10 MB maximum profile image download.
      final bytes = await ref.getData(10 * 1024 * 1024);

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Profile photo is empty.');
      }

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _loadingImage = false;
      });

      debugPrint(
        'PROFILE PHOTO LOAD: success (${bytes.length} bytes)',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'PROFILE PHOTO LOAD ERROR: '
        '[${e.plugin}/${e.code}] ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        _imageBytes = null;
        _loadingImage = false;
      });
    } catch (e) {
      debugPrint('PROFILE PHOTO LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _imageBytes = null;
        _loadingImage = false;
      });
    }
  }

  Future<void> _pick(BuildContext context) async {
    if (widget.busy) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(
                  context,
                  ImageSource.gallery,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(
                  context,
                  ImageSource.camera,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (image != null) {
      widget.onImageSelected(image);
    }
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;

    if (_imageBytes != null) {
      child = ClipOval(
        child: Image.memory(
          _imageBytes!,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    } else if (_loadingImage) {
      child = SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Center(
          child: SizedBox(
            width: widget.radius * .42,
            height: widget.radius * .42,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    } else {
      child = Icon(
        Icons.person_outline,
        size: widget.radius * .85,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }

    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildAvatar(context),

            Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.busy
                    ? null
                    : () => _pick(context),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: widget.busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          widget.busy
              ? 'Uploading photo…'
              : _loadingImage
                  ? 'Loading photo…'
                  : widget.label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

