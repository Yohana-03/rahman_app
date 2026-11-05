import 'package:finalrahman/core/formatters.dart';
import 'package:finalrahman/core/storage/preference_store.dart';
import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:finalrahman/core/theme/theme_controller.dart';
import 'package:finalrahman/features/auth/parent_profile.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/ui/home/home_screen.dart';
import 'package:finalrahman/ui/pin/change_pin_screen.dart';
import 'package:finalrahman/ui/students/student_selector_screen.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<PortalController>();
    final theme = context.watch<ThemeController>();
    final profile = portal.profile;
    final student = portal.selected;

    if (portal.loadingProfile && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: portal.loadProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const PageHeader(
              title: 'My Profile',
              subtitle: 'Manage your account and preferences',
            ),
            const SizedBox(height: 30),
            if (portal.profileError != null && profile == null)
              StatusMessage(
                message: portal.profileError!,
                actionLabel: 'Try again',
                onAction: portal.loadProfile,
              )
            else
              _Identity(profile: profile, studentName: student?.name),
            const SizedBox(height: 30),
            const SectionTitle('Account Settings', padding: EdgeInsets.zero),
            const SizedBox(height: 12),
            ProfileTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'View your contact details',
              onTap: () => _showDetails(context, profile),
            ),
            ProfileTile(
              icon: Icons.child_care_outlined,
              title: 'My Children',
              subtitle: student == null
                  ? 'View linked student accounts'
                  : '${portal.students.length} linked • ${student.name}',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StudentSelectorScreen(),
                  ),
                );
              },
            ),
            ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Recent school updates',
              onTap: () => ShellScopeLookup.openUpdates(context),
            ),
            ProfileTile(
              icon: Icons.lock_outline,
              title: 'Change PIN',
              subtitle: 'Update the code that unlocks this device',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ChangePinScreen(),
                  ),
                );
              },
            ),
            SwitchListTile(
              value: theme.preference == ThemePreference.dark,
              onChanged: (value) {
                theme.setPreference(
                  value ? ThemePreference.dark : ThemePreference.light,
                );
              },
              secondary: Icon(
                Icons.dark_mode_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: portalInk(context),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            ProfileTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get assistance from the school',
              onTap: () => _showHelp(context),
            ),
            ProfileTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: AppColors.red,
              onTap: () => _confirmLogout(context),
            ),
            const SizedBox(height: 25),
            Center(
              child: Text(
                'PARENT PORTAL • VERSION 1.0.0',
                style: TextStyle(
                  color: portalMuted(context),
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ParentProfile? profile) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: profile == null
                ? const Text('Profile details are not available yet.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: portalInk(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      InfoRow(label: 'Name', value: profile.name),
                      InfoRow(label: 'Email', value: profile.email),
                      InfoRow(label: 'Phone', value: profile.phoneNumber),
                      InfoRow(
                        label: 'Address',
                        value: profile.details?.address ?? '',
                      ),
                      InfoRow(
                        label: 'Emergency',
                        value: profile.details?.emergencyContactNumber ?? '',
                      ),
                      InfoRow(
                        label: 'Relationship',
                        value: titleCase(
                          profile.details?.emergencyContactRelationship,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For account, fee, or result questions, contact the Rahman Academy school office. They manage parent access and published records.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final session = context.read<SessionController>();
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

class _Identity extends StatelessWidget {
  const _Identity({required this.profile, required this.studentName});

  final ParentProfile? profile;
  final String? studentName;

  @override
  Widget build(BuildContext context) {
    final name = profile?.name ?? 'Parent';
    final phone = profile?.phoneNumber ?? '';
    return Column(
      children: [
        InitialsAvatar(name: name, radius: 43),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: portalInk(context),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          titleCase(profile?.role ?? 'Parent'),
          style: TextStyle(color: portalMuted(context), fontSize: 12),
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            phone,
            style: TextStyle(color: portalMuted(context), fontSize: 12),
          ),
        ] else if (profile?.email.isNotEmpty == true) ...[
          const SizedBox(height: 5),
          Text(
            profile!.email,
            style: TextStyle(color: portalMuted(context), fontSize: 12),
          ),
        ],
        if (studentName != null) ...[
          const SizedBox(height: 5),
          Text(
            'Viewing $studentName',
            style: TextStyle(color: portalMuted(context), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

/// Opens the same updates sheet the home screen uses, without a shell import cycle.
class ShellScopeLookup {
  static void openUpdates(BuildContext context) {
    final portal = context.read<PortalController>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final activities = recentActivities(portal);
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: portalInk(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Recent payments and published results',
                style: TextStyle(fontSize: 12, color: portalMuted(context)),
              ),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                Text(
                  'No notifications yet.',
                  style: TextStyle(color: portalMuted(context), fontSize: 12),
                )
              else
                for (final activity in activities)
                  ActivityTile(
                    icon: activity.icon,
                    title: activity.title,
                    subtitle: activity.subtitle,
                    color: activity.color,
                  ),
            ],
          ),
        );
      },
    );
  }
}
