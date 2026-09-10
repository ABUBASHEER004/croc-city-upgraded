import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../services/profile_photo_service.dart';
import '../widgets/profile_photo_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;

  Future<void> _changePhoto(XFile file) async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _uploading = true);
    try {
      await ProfilePhotoService.instance.uploadUserPhoto(
        uid: user.uid,
        file: file,
      );
      await auth.refreshCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update photo: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _logout() async {
    if (_uploading) return;

    try {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      // The router/splash/auth state handles the session transition.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No profile available.')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ProfilePhotoPicker(
                    photoUrl: user.photoUrl,
                    busy: _uploading,
                    onImageSelected: _changePhoto,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(user.email),
                  const SizedBox(height: 10),
                  Chip(
                    avatar: const Icon(Icons.badge_outlined, size: 18),
                    label: Text(user.role),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone.isEmpty ? 'Not provided' : user.phone,
          ),
          _InfoTile(
            icon: Icons.verified_user_outlined,
            label: 'Email status',
            value: user.emailVerified ? 'Verified' : 'Not verified',
          ),
          _InfoTile(
            icon: Icons.shield_outlined,
            label: 'Account role',
            value: user.role,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile details'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: auth.loading ? null : _logout,
            icon: auth.loading
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: Text(auth.loading ? 'Signing out…' : 'Sign out'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
