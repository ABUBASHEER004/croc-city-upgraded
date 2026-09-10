import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/player.dart';
import '../../../../services/profile_photo_service.dart';
import '../providers/player_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../../../coaches/presentation/providers/coach_provider.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emergencyController = TextEditingController();
  final medicalController = TextEditingController();
  final guardianController = TextEditingController();
  final guardianPhoneController = TextEditingController();
  final jerseyController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  final Uuid uuid = const Uuid();

  DateTime? dob;

  String gender = 'Male';
  String position = 'Forward';
  String preferredFoot = 'Right';
  String? selectedTeam;
  String? selectedCoach;

  XFile? image;

  bool loading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emergencyController.dispose();
    medicalController.dispose();
    guardianController.dispose();
    guardianPhoneController.dispose();
    jerseyController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK PLAYER IMAGE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked == null) return;

      if (!mounted) return;

      setState(() {
        image = picked;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // PICK DATE OF BIRTH
  // ============================================================

  Future<void> pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2012),
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'SELECT DATE OF BIRTH',
    );

    if (date == null) return;

    if (!mounted) return;

    setState(() {
      dob = date;
    });
  }

  // ============================================================
  // REGISTRATION NUMBER
  // ============================================================

  String generateRegistrationNumber() {
    final year = DateTime.now().year;

    final unique =
        DateTime.now().microsecondsSinceEpoch.toString().substring(8);

    return 'CCA-$year-$unique';
  }

  // ============================================================
  // SHOW ERROR
  // ============================================================

  void showMessage(
    String message, {
    bool error = true,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ============================================================
  // SAVE PLAYER
  // ============================================================

  Future<void> savePlayer() async {
    // Prevent double tapping
    if (loading) return;

    // Close keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date of birth
    if (dob == null) {
      showMessage('Please select the player\'s date of birth.');
      return;
    }

    // Validate team
    if (selectedTeam == null || selectedTeam!.trim().isEmpty) {
      showMessage('Please select a team.');
      return;
    }

    // Validate jersey number
    final jerseyNumber =
        int.tryParse(jerseyController.text.trim());

    if (jerseyNumber == null || jerseyNumber <= 0) {
      showMessage('Please enter a valid jersey number.');
      return;
    }

    // Start loading
    setState(() {
      loading = true;
    });

    try {
      context.read<CoachProvider>().listenToCoaches();
      final playerProvider = context.read<PlayerProvider>();

      // --------------------------------------------------------
      // CHECK DUPLICATE JERSEY NUMBER
      // --------------------------------------------------------

      final jerseyExists =
          await playerProvider.jerseyNumberExists(
        teamId: selectedTeam!,
        jerseyNumber: jerseyNumber,
      );

      if (jerseyExists) {
        throw Exception(
          'Jersey number $jerseyNumber is already assigned to another player in this team.',
        );
      }

      // --------------------------------------------------------
      // GENERATE REGISTRATION NUMBER
      // --------------------------------------------------------

      String registrationNumber =
          generateRegistrationNumber();

      // Make sure registration number is unique
      int attempts = 0;

      while (await playerProvider
          .registrationExists(registrationNumber)) {
        registrationNumber =
            generateRegistrationNumber();

        attempts++;

        if (attempts >= 5) {
          throw Exception(
            'Unable to generate a unique registration number. Please try again.',
          );
        }
      }

      // --------------------------------------------------------
      // CREATE PLAYER
      // --------------------------------------------------------

      final player = Player(
        id: uuid.v4(),
        registrationNo: registrationNumber,

        // Personal information
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        gender: gender,
        dateOfBirth: dob!,

        // Academy information
        teamId: selectedTeam!,
        coachId: selectedCoach ?? '',
        position: position,
        jerseyNumber: jerseyNumber,
        preferredFoot: preferredFoot,

        // Parent / guardian
        parentName: guardianController.text.trim(),
        parentPhone: guardianPhoneController.text.trim(),

        // Emergency / medical
        emergencyContact: emergencyController.text.trim(),
        medicalNotes: medicalController.text.trim(),

        // Image
        // Image upload can be added separately through Firebase Storage.
        photoUrl: '',

        // Status
        active: true,

        // Created
        createdAt: DateTime.now(),
      );

      // --------------------------------------------------------
      // SAVE TO FIRESTORE
      // --------------------------------------------------------

      await playerProvider.addPlayer(player);

      // Upload the selected photo only after the player document exists.
      // If the photo upload fails, the player record remains safely created
      // and the administrator can add the photo later.
      if (image != null) {
        try {
          final photoUrl =
              await ProfilePhotoService.instance.uploadPlayerPhoto(
            playerId: player.id,
            file: image!,
          );

          await playerProvider.updatePlayer(
            player.copyWith(photoUrl: photoUrl),
          );
        } catch (photoError) {
          if (mounted) {
            showMessage(
              'Player was added, but the photo could not be uploaded: $photoError',
              error: false,
            );
          }
        }
      }

      if (!mounted) return;

      // Success
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Player added successfully!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      // Return to Players screen
      if (context.mounted) {
  context.go('/players');
}
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Failed to add player.\n\n$e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon) : null,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    final coachProvider = context.watch<CoachProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Player',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // ==================================================
                  // PLAYER PHOTO
                  // ==================================================

                  Center(
                    child: GestureDetector(
                      onTap: loading ? null : pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            child: image == null
                                ? const Icon(Icons.person, size: 55)
                                : FutureBuilder<Uint8List>(
                                    future: image!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        );
                                      }
                                      return ClipOval(
                                        child: Image.memory(
                                          snapshot.data!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      'Tap to add player photo',
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // PERSONAL INFORMATION
                  // ==================================================

                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: firstNameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: inputDecoration(
                      label: 'First Name',
                      icon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'First name is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: lastNameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: inputDecoration(
                      label: 'Last Name',
                      icon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Last name is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: inputDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: inputDecoration(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: addressController,
                    textCapitalization:
                        TextCapitalization.sentences,
                    maxLines: 2,
                    decoration: inputDecoration(
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // DATE OF BIRTH
                  // ==================================================

                  const Text(
                    'Date of Birth',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed:
                          loading ? null : pickDate,
                      icon: const Icon(
                        Icons.calendar_today,
                      ),
                      label: Text(
                        dob == null
                            ? 'Select Date of Birth'
                            : '${dob!.day.toString().padLeft(2, '0')}/'
                                '${dob!.month.toString().padLeft(2, '0')}/'
                                '${dob!.year}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // GENDER
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue: gender,
                    decoration: inputDecoration(
                      label: 'Gender',
                      icon: Icons.wc_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Male',
                        child: Text('Male'),
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child: Text('Female'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              gender = value;
                            });
                          },
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // ACADEMY INFORMATION
                  // ==================================================

                  const Text(
                    'Academy Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // TEAM
                  DropdownButtonFormField<String>(
                    initialValue: selectedTeam,
                    decoration: inputDecoration(
                      label: 'Team',
                      icon: Icons.groups_outlined,
                    ),
                    hint: const Text(
                      'Select team',
                    ),
                    items: teamProvider.teams
                        .map(
                          (team) =>
                              DropdownMenuItem<String>(
                            value: team.id,
                            child: Text(
                              team.name,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: loading
                        ? null
                        : (value) {
                            setState(() {
                              selectedTeam = value;
                            });
                          },
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please select a team';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCoach,
                    decoration: inputDecoration(
                      label: 'Coach',
                      icon: Icons.sports_outlined,
                    ),
                    hint: const Text('Assign coach (optional)'),
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
                    onChanged: loading ? null : (value) => setState(() => selectedCoach = value),
                  ),

                  const SizedBox(height: 16),

                  // POSITION
                  DropdownButtonFormField<String>(
                    initialValue: position,
                    decoration: inputDecoration(
                      label: 'Position',
                      icon: Icons.sports_soccer,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Goalkeeper',
                        child: Text('Goalkeeper'),
                      ),
                      DropdownMenuItem(
                        value: 'Defender',
                        child: Text('Defender'),
                      ),
                      DropdownMenuItem(
                        value: 'Midfielder',
                        child: Text('Midfielder'),
                      ),
                      DropdownMenuItem(
                        value: 'Forward',
                        child: Text('Forward'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              position = value;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  // JERSEY NUMBER
                  TextFormField(
                    controller: jerseyController,
                    keyboardType:
                        TextInputType.number,
                    decoration: inputDecoration(
                      label: 'Jersey Number',
                      icon: Icons.tag,
                      hint: 'e.g. 10',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Jersey number is required';
                      }

                      final number =
                          int.tryParse(value.trim());

                      if (number == null ||
                          number <= 0) {
                        return 'Enter a valid jersey number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // PREFERRED FOOT
                  DropdownButtonFormField<String>(
                    initialValue: preferredFoot,
                    decoration: inputDecoration(
                      label: 'Preferred Foot',
                      icon: Icons.directions_run,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Right',
                        child: Text('Right'),
                      ),
                      DropdownMenuItem(
                        value: 'Left',
                        child: Text('Left'),
                      ),
                      DropdownMenuItem(
                        value: 'Both',
                        child: Text('Both'),
                      ),
                    ],
                    onChanged: loading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              preferredFoot = value;
                            });
                          },
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // PARENT / GUARDIAN
                  // ==================================================

                  const Text(
                    'Parent / Guardian Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: guardianController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: inputDecoration(
                      label: 'Parent / Guardian Name',
                      icon: Icons.family_restroom,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                        guardianPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: inputDecoration(
                      label: 'Parent / Guardian Phone',
                      icon: Icons.phone,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // EMERGENCY CONTACT
                  // ==================================================

                  const Text(
                    'Emergency & Medical Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emergencyController,
                    keyboardType: TextInputType.phone,
                    decoration: inputDecoration(
                      label: 'Emergency Contact',
                      icon: Icons.emergency,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: medicalController,
                    maxLines: 4,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: inputDecoration(
                      label: 'Medical Notes',
                      icon: Icons.medical_information_outlined,
                      hint: 'Allergies, conditions, etc.',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // ADD PLAYER BUTTON
                  // ==================================================

                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          loading ? null : savePlayer,
                      icon: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.person_add,
                            ),
                      label: Text(
                        loading
                            ? 'Adding Player...'
                            : 'Add Player',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // ========================================================
          // LOADING OVERLAY
          // ========================================================

          if (loading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black26,
                ),
              ),
            ),
        ],
      ),
    );
  }
}