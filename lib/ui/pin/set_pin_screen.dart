import 'package:finalrahman/core/api_config.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/ui/pin/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _first = '';
  String _pin = '';
  bool _confirming = false;
  String? _error;

  void _add(String digit) {
    if (_pin.length >= pinLength) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == pinLength) {
      Future<void>.delayed(const Duration(milliseconds: 120), _advance);
    }
  }

  Future<void> _advance() async {
    if (!mounted || _pin.length != pinLength) return;
    if (!_confirming) {
      setState(() {
        _first = _pin;
        _pin = '';
        _confirming = true;
      });
      return;
    }
    if (_pin != _first) {
      setState(() {
        _error = 'Those PINs do not match. Start again.';
        _pin = '';
        _first = '';
        _confirming = false;
      });
      return;
    }
    await context.read<SessionController>().completePinSetup(_pin);
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: PinEntryView(
        title: _confirming ? 'Confirm your PIN' : 'Create a PIN',
        subtitle: _confirming
            ? 'Enter the same 4 digits again.'
            : 'You will use this PIN the next time you open Rahman.',
        pin: _pin,
        error: _error,
        onDigit: _add,
        onBackspace: _backspace,
        footer: TextButton(
          onPressed: () => context.read<SessionController>().logout(),
          child: const Text('Sign out'),
        ),
      ),
    );
  }
}
