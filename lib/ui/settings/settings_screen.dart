import 'package:finalrahman/core/storage/preference_store.dart';
import 'package:finalrahman/core/theme/theme_controller.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/ui/pin/change_pin_screen.dart';
import 'package:finalrahman/ui/students/student_selector_screen.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final session = context.read<SessionController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          ParentMenuButton(
            onSelectStudents: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StudentSelectorScreen(),
                ),
              );
            },
            onSettings: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionTitle('Appearance', padding: EdgeInsets.zero),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose light or dark mode for this device.'),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemePreference>(
                    selected: {theme.preference},
                    onSelectionChanged: (values) {
                      theme.setPreference(values.first);
                    },
                    segments: const [
                      ButtonSegment(
                        value: ThemePreference.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemePreference.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(
            'Security',
            padding: EdgeInsets.only(top: 20, bottom: 8),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: const Text('Change PIN'),
                  subtitle: const Text('Update the code that unlocks the app'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ChangePinScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log out'),
                  subtitle: const Text('Sign in again and set a new PIN'),
                  onTap: () => _confirmLogout(context, session),
                ),
              ],
            ),
          ),
          const SectionTitle(
            'About',
            padding: EdgeInsets.only(top: 20, bottom: 8),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.school_outlined),
              title: Text('Rahman Parent Portal'),
              subtitle: Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    SessionController session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'This device will forget the saved session and PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await session.logout();
    }
  }
}
