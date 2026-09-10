
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/player.dart';
import '../../../../services/profile_photo_service.dart';
import '../../../profile/presentation/widgets/profile_photo_picker.dart';
import '../providers/player_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../../../coaches/presentation/providers/coach_provider.dart';

import '../widgets/date_picker_field.dart';
import '../widgets/gender_dropdown.dart';
import '../widgets/position_dropdown.dart';
import '../widgets/preferred_foot_dropdown.dart';
import '../widgets/team_dropdown.dart';
import '../widgets/player_form_section.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/save_player_button.dart';

class EditPlayerScreen extends StatefulWidget {
  const EditPlayerScreen({
    super.key,
    required this.playerId,
  });

  final String playerId;

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {};

  Player? _player;

  bool _loading = true;
  bool _saving = false;

  String _gender = 'Male';
  String _position = 'Forward';
  String _preferredFoot = 'Right';

  String? _teamId;
  String? _coachId;
  DateTime? _dateOfBirth;
  XFile? _selectedPhoto;
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TeamProvider>().listenToTeams();
      context.read<CoachProvider>().listenToCoaches();
      _loadPlayer();
    });
  }

  Future<void> _loadPlayer() async {
    try {
      final player = await context
          .read<PlayerProvider>()
          .getPlayer(widget.playerId);

      if (!mounted) return;

      if (player == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      _disposeControllers();

      _player = player;

      _controllers.addAll({
        'first': TextEditingController(text: player.firstName),
        'last': TextEditingController(text: player.lastName),
        'email': TextEditingController(text: player.email),
        'phone': TextEditingController(text: player.phone),
        'address': TextEditingController(text: player.address),
        'jersey': TextEditingController(
          text: player.jerseyNumber.toString(),
        ),
        'parent': TextEditingController(text: player.parentName),
        'parentPhone': TextEditingController(text: player.parentPhone),
        'emergency': TextEditingController(
          text: player.emergencyContact,
        ),
        'medical': TextEditingController(
          text: player.medicalNotes,
        ),
      });

      _gender = player.gender;
      _position = player.position;
      _preferredFoot = player.preferredFoot;
      _teamId = player.teamId;
      _coachId = player.coachId;
      _dateOfBirth = player.dateOfBirth;
      _photoUrl = player.photoUrl;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load player: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    _controllers.clear();
  }

  TextEditingController _controller(String key) {
    return _controllers[key]!;
  }

  Future<void> _savePlayer() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_player == null) {
      _showMessage('Player information is unavailable.');
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage('Please select the player\'s date of birth.');
      return;
    }

    if (_teamId == null || _teamId!.isEmpty) {
      _showMessage('Please select a team.');
      return;
    }

    final jerseyNumber = int.tryParse(
      _controller('jersey').text.trim(),
    );

    if (jerseyNumber == null || jerseyNumber <= 0) {
      _showMessage('Please enter a valid jersey number.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final teamId = _teamId!;

      final jerseyExists = await context
          .read<PlayerProvider>()
          .jerseyNumberExists(
            teamId: teamId,
            jerseyNumber: jerseyNumber,
          );

      if (!mounted) return;

      final teamChanged = teamId != _player!.teamId;
      final jerseyChanged =
          jerseyNumber != _player!.jerseyNumber;

      if (jerseyExists && (teamChanged || jerseyChanged)) {
        throw Exception(
          'Jersey number $jerseyNumber is already assigned '
          'to another player in this team.',
        );
      }

      final updatedPlayer = _player!.copyWith(
        firstName: _controller('first').text.trim(),
        lastName: _controller('last').text.trim(),
        email: _controller('email').text.trim(),
        phone: _controller('phone').text.trim(),
        address: _controller('address').text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        teamId: teamId,
        coachId: _coachId ?? '',
        position: _position,
        jerseyNumber: jerseyNumber,
        preferredFoot: _preferredFoot,
        parentName: _controller('parent').text.trim(),
        parentPhone: _controller('parentPhone').text.trim(),
        emergencyContact: _controller('emergency').text.trim(),
        medicalNotes: _controller('medical').text.trim(),
      );

      await context
          .read<PlayerProvider>()
          .updatePlayer(updatedPlayer);

      if (_selectedPhoto != null) {
        final photoUrl =
            await ProfilePhotoService.instance.uploadPlayerPhoto(
          playerId: updatedPlayer.id,
          file: _selectedPhoto!,
        );
        await context.read<PlayerProvider>().updatePlayer(
          updatedPlayer.copyWith(photoUrl: photoUrl),
        );
        _photoUrl = photoUrl;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Player updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update player: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _jerseyValidator(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a valid number';
    }

    return null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Player'),
        ),
        body: const Center(
          child: Text(
            'Player not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Player'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfilePhotoPicker(
              photoUrl: _photoUrl,
              busy: _saving,
              onImageSelected: (file) =>
                  setState(() => _selectedPhoto = file),
              label: 'Change player photo',
            ),
            const SizedBox(height: 24),
            PlayerFormSection(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                TextFormField(
                  controller: _controller('first'),
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    'First Name',
                    Icons.person,
                  ),
                  validator: _requiredValidator,
                ),

                TextFormField(
                  controller: _controller('last'),
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    'Last Name',
                    Icons.person,
                  ),
                  validator: _requiredValidator,
                ),

                TextFormField(
                  controller: _controller('email'),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                ),

                TextFormField(
                  controller: _controller('phone'),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    'Phone',
                    Icons.phone_outlined,
                  ),
                ),

                TextFormField(
                  controller: _controller('address'),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    'Address',
                    Icons.home_outlined,
                  ),
                ),

                GenderDropdown(
                  value: _gender,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _gender = value;
                    });
                  },
                ),

                DatePickerField(
                  label: 'Date of Birth',
                  value: _dateOfBirth,
                  onChanged: (value) {
                    setState(() {
                      _dateOfBirth = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Required';
                    }

                    return null;
                  },
                ),
              ],
            ),

            PlayerFormSection(
              title: 'Academy Information',
              icon: Icons.sports_soccer,
              children: [
                TeamDropdown(
                  value: _teamId,
                  onChanged: (value) {
                    setState(() {
                      _teamId = value;
                    });
                  },
                ),

                Consumer<CoachProvider>(
                  builder: (context, coachProvider, _) => DropdownButtonFormField<String>(
                    initialValue: _coachId,
                    decoration: const InputDecoration(
                      labelText: 'Coach',
                      prefixIcon: Icon(Icons.sports_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('No coach assigned yet'),
                      ),
                      ...coachProvider.coaches.where((coach) => coach.active).map(
                        (coach) => DropdownMenuItem<String>(
                          value: coach.id,
                          child: Text(coach.fullName),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _coachId = value),
                  ),
                ),

                PositionDropdown(
                  value: _position,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _position = value;
                    });
                  },
                ),

                TextFormField(
                  controller: _controller('jersey'),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'Jersey Number',
                    Icons.numbers,
                  ),
                  validator: _jerseyValidator,
                ),

                PreferredFootDropdown(
                  value: _preferredFoot,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _preferredFoot = value;
                    });
                  },
                ),
              ],
            ),

            EmergencyContactCard(
              parentNameController: _controller('parent'),
              parentPhoneController: _controller('parentPhone'),
              emergencyContactController:
                  _controller('emergency'),
            ),

            PlayerFormSection(
              title: 'Medical Information',
              icon: Icons.medical_information_outlined,
              children: [
                TextFormField(
                  controller: _controller('medical'),
                  maxLines: 4,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    'Medical Notes',
                    Icons.note_alt_outlined,
                  ),
                ),
              ],
            ),

            SavePlayerButton(
              loading: _saving,
              label: 'Update Player',
              onPressed: _saving ? null : _savePlayer,
            ),
          ],
        ),
      ),
    );
  }
}
