import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/team.dart';
import '../providers/team_provider.dart';

class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({super.key});

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _coachIdController = TextEditingController();
  final _assistantCoachIdController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _homeKitColorController = TextEditingController();
  final _awayKitColorController = TextEditingController();

  String _ageGroup = 'U-10';
  String _category = 'Youth';
  bool _active = true;
  bool _isSaving = false;

  final List<String> _ageGroups = [
    'U-10',
    'U-13',
    'U-15',
    'U-17',
    'U-20',
    'Senior',
  ];

  final List<String> _categories = [
    'Youth',
    'Academy',
    'Junior',
    'Senior',
    'Professional',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _coachIdController.dispose();
    _assistantCoachIdController.dispose();
    _logoUrlController.dispose();
    _homeKitColorController.dispose();
    _awayKitColorController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final team = Team(
        id: '',
        name: _nameController.text.trim(),
        ageGroup: _ageGroup,
        category: _category,
        coachId: _coachIdController.text.trim(),
        assistantCoachId: _assistantCoachIdController.text.trim(),
        logoUrl: _logoUrlController.text.trim(),
        homeKitColor: _homeKitColorController.text.trim(),
        awayKitColor: _awayKitColorController.text.trim(),
        active: _active,
        createdAt: DateTime.now(),
      );

      await context.read<TeamProvider>().addTeam(team);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team created successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create team: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Team'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // Header icon
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.groups,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Create New Team',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Add a new team to Croc City Football Academy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 30),

                // Team Name
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Team Name',
                    hint: 'e.g. Croc City U-17',
                    icon: Icons.groups_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter team name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Age Group
                DropdownButtonFormField<String>(
                  value: _ageGroup,
                  decoration: _inputDecoration(
                    label: 'Age Group',
                    icon: Icons.cake_outlined,
                  ),
                  items: _ageGroups.map((age) {
                    return DropdownMenuItem(
                      value: age,
                      child: Text(age),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _ageGroup = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                // Category
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDecoration(
                    label: 'Category',
                    icon: Icons.category_outlined,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                // Coach ID
                TextFormField(
                  controller: _coachIdController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Coach ID',
                    hint: 'Enter coach user ID',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter coach ID';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Assistant Coach ID
                TextFormField(
                  controller: _assistantCoachIdController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Assistant Coach ID',
                    hint: 'Enter assistant coach ID',
                    icon: Icons.person_add_alt_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // Logo URL
                TextFormField(
                  controller: _logoUrlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Logo URL',
                    hint: 'https://example.com/logo.png',
                    icon: Icons.image_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // Home Kit Color
                TextFormField(
                  controller: _homeKitColorController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Home Kit Color',
                    hint: 'e.g. Green',
                    icon: Icons.sports_soccer_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // Away Kit Color
                TextFormField(
                  controller: _awayKitColorController,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(
                    label: 'Away Kit Color',
                    hint: 'e.g. White',
                    icon: Icons.sports_soccer,
                  ),
                ),

                const SizedBox(height: 12),

                // Active switch
                Card(
                  elevation: 0,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    title: const Text(
                      'Active Team',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Enable this team in the academy',
                    ),
                    secondary: const Icon(
                      Icons.toggle_on_outlined,
                    ),
                    value: _active,
                    onChanged: (value) {
                      setState(() {
                        _active = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // Create button
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _createTeam,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      _isSaving
                          ? 'Creating Team...'
                          : 'Create Team',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}