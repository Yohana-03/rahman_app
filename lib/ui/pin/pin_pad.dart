import 'package:finalrahman/core/api_config.dart';
import 'package:flutter/material.dart';

class PinEntryView extends StatelessWidget {
  const PinEntryView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pin,
    required this.onDigit,
    required this.onBackspace,
    this.error,
    this.footer,
  });

  final String title;
  final String subtitle;
  final String pin;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final String? error;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 28),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < pinLength; i++)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < pin.length ? scheme.primary : Colors.transparent,
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 24,
            child: Text(
              error ?? '',
              style: TextStyle(
                color: scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxHeight < 420 ? 64.0 : 74.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final row in const [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final digit in row)
                              _Key(
                                size: size,
                                label: digit,
                                onTap: () => onDigit(digit),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: size + 18, height: size),
                          _Key(
                            size: size,
                            label: '0',
                            onTap: () => onDigit('0'),
                          ),
                          _Key(
                            size: size,
                            icon: Icons.backspace_outlined,
                            onTap: onBackspace,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ?footer,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.size, required this.onTap, this.label, this.icon});

  final double size;
  final VoidCallback onTap;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: icon != null
                  ? Icon(icon)
                  : Text(
                      label ?? '',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
