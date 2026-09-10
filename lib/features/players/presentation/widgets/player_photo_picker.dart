import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Cross-platform player photo picker preview.
///
/// Uses XFile.readAsBytes instead of dart:io/File so the same widget works on
/// Android, iOS, Windows, macOS, Linux and Flutter Web.
class PlayerPhotoPicker extends StatefulWidget {
  const PlayerPhotoPicker({
    super.key,
    this.image,
    this.imageUrl = '',
    required this.onPick,
  });

  final XFile? image;
  final String imageUrl;
  final Future<void> Function() onPick;

  @override
  State<PlayerPhotoPicker> createState() => _PlayerPhotoPickerState();
}

class _PlayerPhotoPickerState extends State<PlayerPhotoPicker> {
  Future<Uint8List>? _bytesFuture;

  @override
  void initState() {
    super.initState();
    _prepareImage();
  }

  @override
  void didUpdateWidget(covariant PlayerPhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image?.path != widget.image?.path) {
      _prepareImage();
    }
  }

  void _prepareImage() {
    final image = widget.image;
    _bytesFuture = image?.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = 52.0;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FutureBuilder<Uint8List>(
            future: _bytesFuture,
            builder: (context, snapshot) {
              ImageProvider? provider;
              if (snapshot.hasData) {
                provider = MemoryImage(snapshot.data!);
              } else if (widget.imageUrl.trim().isNotEmpty) {
                provider = NetworkImage(widget.imageUrl.trim());
              }

              return CircleAvatar(
                radius: radius,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: provider,
                child: provider == null
                    ? Icon(
                        Icons.person_outline,
                        size: 52,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              );
            },
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                tooltip: 'Choose player photo',
                onPressed: widget.onPick,
                color: theme.colorScheme.onPrimary,
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
