import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CoachPhotoPicker extends StatelessWidget {
  const CoachPhotoPicker({
    super.key,
    required this.onImageSelected,
    this.photoUrl,
    this.busy = false,
  });

  final ValueChanged<XFile> onImageSelected;
  final String? photoUrl;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 58,
              backgroundImage:
                  photoUrl != null && photoUrl!.isNotEmpty
                      ? NetworkImage(photoUrl!)
                      : null,
              child: photoUrl == null || photoUrl!.isEmpty
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: busy
                  ? null
                  : () async {
                      final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 82,
                        maxWidth: 1200,
                        maxHeight: 1200,
                      );
                      if (image != null) onImageSelected(image);
                    },
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          busy ? 'Saving coach…' : 'Add coach profile photo',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
