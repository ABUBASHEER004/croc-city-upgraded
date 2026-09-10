
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/coach.dart';
import '../../../../services/profile_photo_service.dart';
import '../widgets/coach_photo_picker.dart';
import '../providers/coach_provider.dart';

class EditCoachScreen extends StatefulWidget {
  const EditCoachScreen({super.key, required this.coachId});
  final String coachId;

  @override
  State<EditCoachScreen> createState() => _EditCoachScreenState();
}

class _EditCoachScreenState extends State<EditCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _specialty = TextEditingController();
  final _license = TextEditingController();
  final _experience = TextEditingController();
  final _photo = TextEditingController();
  final _bio = TextEditingController();
  bool _active = true;
  bool _loading = true;
  bool _saving = false;
  Coach? _coach;
  XFile? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final coach = await context.read<CoachProvider>().getCoach(widget.coachId);
    if (!mounted) return;
    if (coach == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coach profile not found.')),
      );
      context.go('/coaches');
      return;
    }
    _coach = coach;
    _first.text = coach.firstName;
    _last.text = coach.lastName;
    _email.text = coach.email;
    _phone.text = coach.phone;
    _specialty.text = coach.specialty;
    _license.text = coach.licenseNumber;
    _experience.text = coach.experience;
    _photo.text = coach.photoUrl;
    _bio.text = coach.bio;
    _active = coach.active;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _specialty, _license,
      _experience, _photo, _bio]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _coach == null) return;
    setState(() => _saving = true);
    try {
      await context.read<CoachProvider>().updateCoach(_coach!.copyWith(
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
      ));

      if (_selectedPhoto != null) {
        await ProfilePhotoService.instance.uploadCoachPhoto(
          coachId: widget.coachId,
          file: _selectedPhoto!,
        );
      }

      if (mounted) context.go('/coaches/details/${widget.coachId}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Coach'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CoachPhotoPicker(
              photoUrl: _coach?.photoUrl,
              busy: _saving,
              onImageSelected: (file) =>
                  setState(() => _selectedPhoto = file),
            ),
            const SizedBox(height: 24),
            ...[
              [_first, 'First name', Icons.person_outline, true],
              [_last, 'Last name', Icons.person_outline, true],
              [_email, 'Email address', Icons.email_outlined, true],
              [_phone, 'Phone number', Icons.phone_outlined, true],
              [_specialty, 'Coaching specialty', Icons.sports_soccer, true],
              [_license, 'Licence / certification', Icons.workspace_premium_outlined, false],
              [_experience, 'Experience', Icons.timeline_outlined, false],
              [_photo, 'Profile photo URL', Icons.image_outlined, false],
              [_bio, 'Professional bio', Icons.notes_outlined, false],
            ].map((item) {
              final c = item[0] as TextEditingController;
              final label = item[1] as String;
              final icon = item[2] as IconData;
              final required = item[3] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: c,
                  maxLines: label == 'Professional bio' ? 4 : 1,
                  validator: (v) => required && (v == null || v.trim().isEmpty)
                      ? '$label is required' : null,
                  decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
                ),
              );
            }),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active coach'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
          ],
        ),
      ),
    );
  }
}
