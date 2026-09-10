
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/coach.dart';
import '../../../../services/profile_photo_service.dart';
import '../widgets/coach_photo_picker.dart';
import '../providers/coach_provider.dart';

class AddCoachScreen extends StatefulWidget {
  const AddCoachScreen({super.key});

  @override
  State<AddCoachScreen> createState() => _AddCoachScreenState();
}

class _AddCoachScreenState extends State<AddCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _specialty = TextEditingController(text: 'Youth Development');
  final _license = TextEditingController();
  final _experience = TextEditingController();
  final _photo = TextEditingController();
  final _bio = TextEditingController();
  bool _active = true;
  bool _saving = false;
  XFile? _selectedPhoto;

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _specialty, _license,
      _experience, _photo, _bio]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final coachId = const Uuid().v4();

      final coach = Coach(
        id: coachId,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        specialty: _specialty.text.trim(),
        licenseNumber: _license.text.trim(),
        experience: _experience.text.trim(),
        photoUrl: _photo.text.trim(),
        bio: _bio.text.trim(),
        active: _active,
        createdAt: DateTime.now(),
      );

      await context.read<CoachProvider>().addCoach(coach);

      if (_selectedPhoto != null) {
        try {
          await ProfilePhotoService.instance.uploadCoachPhoto(
            coachId: coachId,
            file: _selectedPhoto!,
          );
        } catch (photoError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Coach saved, but the photo could not be uploaded: $photoError',
                ),
              ),
            );
          }
        }
      }

      if (mounted) context.go('/coaches');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _CoachFormScaffold(
    title: 'Add Coach',
    saving: _saving,
    onSave: _save,
    formKey: _formKey,
    children: _fields(),
  );

  List<Widget> _fields() => [
    CoachPhotoPicker(
      onImageSelected: (file) => setState(() => _selectedPhoto = file),
      busy: _saving,
    ), 
    const SizedBox(height: 24),
    _field(_first, 'First name', Icons.person_outline),
    _field(_last, 'Last name', Icons.person_outline),
    _field(_email, 'Email address', Icons.email_outlined,
      keyboard: TextInputType.emailAddress),
    _field(_phone, 'Phone number', Icons.phone_outlined,
      keyboard: TextInputType.phone),
    _field(_specialty, 'Coaching specialty', Icons.sports_soccer),
    _field(_license, 'Coaching licence / certification', Icons.workspace_premium_outlined,
      required: false),
    _field(_experience, 'Experience (e.g. 8 years)', Icons.timeline_outlined,
      required: false),
    _field(_photo, 'Profile photo URL', Icons.image_outlined, required: false),
    _field(_bio, 'Professional bio', Icons.notes_outlined,
      required: false, maxLines: 4),
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Active coach'),
      subtitle: const Text('Include this coach in active academy operations.'),
      value: _active,
      onChanged: (value) => setState(() => _active = value),
    ),
  ];

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool required = true, TextInputType? keyboard, int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: (v) => required && (v == null || v.trim().isEmpty)
              ? '$label is required'
              : null,
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        ),
      );
}

class _CoachFormScaffold extends StatelessWidget {
  const _CoachFormScaffold({
    required this.title,
    required this.saving,
    required this.onSave,
    required this.formKey,
    required this.children,
  });
  final String title;
  final bool saving;
  final VoidCallback onSave;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(saving ? 'Saving' : 'Save'),
          ),
        ),
      ],
    ),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text('Coach profile',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Keep the technical staff directory accurate and professional.'),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    ),
  );
}
