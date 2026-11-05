import 'package:finalrahman/core/formatters.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/features/portal/student.dart';
import 'package:finalrahman/ui/settings/settings_screen.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentSelectorScreen extends StatefulWidget {
  const StudentSelectorScreen({super.key});

  @override
  State<StudentSelectorScreen> createState() => _StudentSelectorScreenState();
}

class _StudentSelectorScreenState extends State<StudentSelectorScreen> {
  int? _openingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PortalController>().loadStudents();
    });
  }

  Future<void> _choose(Student student) async {
    setState(() => _openingId = student.id);
    await context.read<PortalController>().openStudent(student);
    if (!mounted) return;
    setState(() => _openingId = null);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    context.read<SessionController>().enterPortal();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will sign in with your password and set a new PIN.',
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
    if (confirmed != true || !mounted) return;
    await context.read<SessionController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<PortalController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select students'),
        actions: [
          ParentMenuButton(
            onSelectStudents: () => portal.loadStudents(),
            onSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: portal.loadStudents,
        child: _body(portal),
      ),
    );
  }

  Widget _body(PortalController portal) {
    if (portal.loadingStudents && portal.students.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (portal.studentsError != null && portal.students.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          StatusMessage(
            message: portal.studentsError!,
            icon: Icons.cloud_off_outlined,
            actionLabel: 'Try again',
            onAction: portal.loadStudents,
          ),
          TextButton(onPressed: _logout, child: const Text('Log out')),
        ],
      );
    }
    if (portal.students.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          StatusMessage(
            message: 'No students are linked to this parent account yet.',
            actionLabel: 'Refresh',
            onAction: portal.loadStudents,
          ),
          TextButton(onPressed: _logout, child: const Text('Log out')),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: portal.students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = portal.students[index];
        final selected = portal.selected?.id == student.id;
        final opening = _openingId == student.id;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openingId == null ? () => _choose(student) : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InitialsAvatar(name: student.name),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (student.className.isNotEmpty)
                          Text(student.className),
                        if (student.classTeacher != null)
                          Text('Teacher: ${student.classTeacher}'),
                        if (student.gender != null || student.age != null)
                          Text(
                            [
                              if (student.gender != null)
                                titleCase(student.gender),
                              if (student.age != null) 'Age ${student.age}',
                            ].join(' · '),
                          ),
                      ],
                    ),
                  ),
                  if (opening)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (selected)
                    const Icon(Icons.verified_rounded, color: Color(0xFF16A36A)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
