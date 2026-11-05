import 'package:finalrahman/core/api_config.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/ui/pin/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

enum _PinStep { current, create, confirm }

class _ChangePinScreenState extends State<ChangePinScreen> {
  _PinStep _step = _PinStep.current;
  String _created = '';
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
      Future<void>.delayed(const Duration(milliseconds: 120), _advance);
    }
  }

  Future<void> _advance() async {
    if (!mounted || _pin.length != pinLength || _checking) return;
    if (_step == _PinStep.current) {
      setState(() => _checking = true);
      final matches = await context.read<SessionController>().verifyPin(_pin);
      if (!mounted) return;
      setState(() {
        _checking = false;
        if (matches) {
          _pin = '';
          _step = _PinStep.create;
        } else {
          _pin = '';
          _error = 'That PIN is not correct.';
        }
      });
      return;
    }
    if (_step == _PinStep.create) {
      setState(() {
        _created = _pin;
        _pin = '';
        _step = _PinStep.confirm;
      });
      return;
    }
    if (_pin != _created) {
      setState(() {
        _error = 'Those PINs do not match. Start again.';
        _pin = '';
        _created = '';
        _step = _PinStep.create;
      });
      return;
    }
    await context.read<SessionController>().changePin(_pin);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN updated.')));
    Navigator.of(context).pop();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      _PinStep.current => 'Enter current PIN',
      _PinStep.create => 'Create a new PIN',
      _PinStep.confirm => 'Confirm new PIN',
    };
    final subtitle = switch (_step) {
      _PinStep.current => 'Confirm it is you before changing the lock.',
      _PinStep.create => 'Choose 4 digits you can remember.',
      _PinStep.confirm => 'Enter the new PIN once more.',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Change PIN')),
      body: PinEntryView(
        title: title,
        subtitle: subtitle,
        pin: _pin,
        error: _error,
        onDigit: _add,
        onBackspace: _backspace,
      ),
    );
  }
}
