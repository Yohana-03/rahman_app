import 'package:finalrahman/core/api_config.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/ui/pin/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String? _error;
  bool _checking = false;

  void _add(String digit) {
    if (_checking || _pin.length >= pinLength) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == pinLength) {
      Future<void>.delayed(const Duration(milliseconds: 120), _submit);
    }
  }

  Future<void> _submit() async {
    if (!mounted || _checking) return;
    setState(() => _checking = true);
    final error = await context.read<SessionController>().unlock(_pin);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _pin = '';
      _error = error;
    });
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PinEntryView(
        title: 'Enter your PIN',
        subtitle: 'Unlock Rahman to choose a student.',
        pin: _pin,
        error: _error,
        onDigit: _add,
        onBackspace: _backspace,
        footer: TextButton(
          onPressed: () => context.read<SessionController>().logout(),
          child: const Text('Forgot PIN? Sign in'),
        ),
      ),
    );
  }
}
