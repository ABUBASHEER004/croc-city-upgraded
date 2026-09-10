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
  String? _loadedUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto(widget.photoUrl);
  }

  @override
  void didUpdateWidget(covariant ProfilePhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) _loadPhoto(widget.photoUrl);
  }

  Future<void> _loadPhoto(String? url) async {
    if (url == null || url.isEmpty) {
      if (mounted) setState(() { _imageBytes = null; _loadedUrl = url; });
      return;
    }
    setState(() => _loading = true);
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) throw Exception('Invalid profile photo URL.');
      final segments = uri.pathSegments;
      final objectIndex = segments.indexOf('o');
      if (objectIndex < 0 || objectIndex + 1 >= segments.length) throw Exception('Storage object path could not be read.');
      final objectPath = Uri.decodeComponent(segments[objectIndex + 1]);
      final bytes = await FirebaseStorage.instance.ref().child(objectPath).getData(10 * 1024 * 1024);
      if (bytes == null || bytes.isEmpty) throw Exception('Profile photo returned no data.');
      debugPrint('PROFILE PHOTO LOAD: success');
      if (mounted) setState(() { _imageBytes = bytes; _loadedUrl = url; _loading = false; });
    } catch (e) {
      debugPrint('PROFILE PHOTO LOAD ERROR: $e');
      if (mounted) setState(() { _imageBytes = null; _loadedUrl = url; _loading = false; });
    }
  }

  Future<void> _pick(BuildContext context) async {
    if (widget.busy) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choose from gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Take a photo'), onTap: () => Navigator.pop(context, ImageSource.camera)),
        const SizedBox(height: 8),
      ])),
    );
    if (source == null || !context.mounted) return;
    final image = await ImagePicker().pickImage(source: source, imageQuality: 82, maxWidth: 1200, maxHeight: 1200);
    if (image != null) widget.onImageSelected(image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = _imageBytes != null && _imageBytes!.isNotEmpty;
    final hasUrl = widget.photoUrl != null && widget.photoUrl!.isNotEmpty;
    return Column(children: [
      Stack(alignment: Alignment.bottomRight, children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: hasImage ? MemoryImage(_imageBytes!) : null,
          child: !hasImage ? (_loading || (hasUrl && _loadedUrl != widget.photoUrl) ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.person_outline, size: widget.radius * .85)) : null,
        ),
        Material(color: theme.colorScheme.primary, shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: widget.busy ? null : () => _pick(context), child: Padding(padding: const EdgeInsets.all(9), child: widget.busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 19)))),
      ]),
      const SizedBox(height: 8),
      Text(widget.busy ? 'Uploading photo…' : widget.label, style: theme.textTheme.bodySmall),
    ]);
  }
}
