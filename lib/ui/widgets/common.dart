import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final caption = subtitle?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: portalInk(context),
          ),
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            caption,
            style: TextStyle(fontSize: 12, color: portalMuted(context)),
          ),
        ],
      ],
    );
  }
}

class ArrowLink extends StatelessWidget {
  const ArrowLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: portalInk(context),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: portalCard(context, radius: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(color: portalMuted(context), fontSize: 11),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: portalInk(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 9),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: portalInk(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: portalCard(context, radius: 15),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: portalInk(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(color: portalMuted(context), fontSize: 10),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: portalMuted(context)),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Theme.of(context).colorScheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      leading: Container(
        height: 43,
        width: 43,
        decoration: BoxDecoration(
          color: itemColor.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: itemColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: portalInk(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 10, color: portalMuted(context)),
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: portalMuted(context)),
      onTap: onTap,
    );
  }
}

Color portalInk(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.onSurface
      : AppColors.ink;
}

Color portalMuted(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.onSurfaceVariant
      : AppColors.muted;
}

Color portalBorder(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? theme.colorScheme.outlineVariant
      : AppColors.border;
}

Color portalTint(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? AppColors.brand.withValues(alpha: 0.22)
      : AppColors.secondary;
}

BoxDecoration portalCard(BuildContext context, {double radius = 18}) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: portalBorder(context)),
  );
}

String initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  String letter(String word) => word.characters.first.toUpperCase();
  if (parts.length == 1) return letter(parts.first);
  return '${letter(parts.first)}${letter(parts.last)}';
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 24});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: portalTint(context),
      child: Text(
        initials(name),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: style?.copyWith(color: portalMuted(context)),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: style?.copyWith(
                fontWeight: FontWeight.w600,
                color: portalInk(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: portalTint(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.school_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RAHMAN ACADEMY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  color: portalInk(context),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'School parent account',
                style: TextStyle(color: portalMuted(context), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ParentMenuButton extends StatelessWidget {
  const ParentMenuButton({
    super.key,
    required this.onSelectStudents,
    required this.onSettings,
  });

  final VoidCallback onSelectStudents;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'students') onSelectStudents();
        if (value == 'settings') onSettings();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'students',
          child: Row(
            children: [
              Icon(Icons.groups_outlined),
              SizedBox(width: 12),
              Text('Select students'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
      ],
    );
  }
}
