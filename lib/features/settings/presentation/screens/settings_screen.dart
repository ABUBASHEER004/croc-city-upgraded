import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _notificationsKey = 'settings.notifications';
  static const _soundKey = 'settings.sound';

  bool notifications = true;
  bool sounds = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      notifications = prefs.getBool(_notificationsKey) ?? true;
      sounds = prefs.getBool(_soundKey) ?? true;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Preferences',
            children: [
              SwitchListTile.adaptive(
                value: notifications,
                onChanged: (value) {
                  setState(() => notifications = value);
                  _set(_notificationsKey, value);
                },
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                subtitle: const Text('Receive academy updates and reminders'),
              ),
              SwitchListTile.adaptive(
                value: sounds,
                onChanged: (value) {
                  setState(() => sounds = value);
                  _set(_soundKey, value);
                },
                secondary: const Icon(Icons.volume_up_outlined),
                title: const Text('Sound feedback'),
                subtitle: const Text('Play interface sounds where supported'),
              ),
            ],
          ),
          _Section(
            title: 'Academy',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Croc City Football Academy'),
                subtitle: const Text('Management system'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Croc City Football Academy',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Developing Talent • Building Character • Creating Champions',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy & security'),
                subtitle: const Text('Your academy account is protected by Firebase'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Croc City Football Academy • Professional Academy Management',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...children,
          ],
        ),
      );
}
