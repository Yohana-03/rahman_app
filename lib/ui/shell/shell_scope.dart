import 'package:flutter/material.dart';

class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.openTab, required super.child});

  final ValueChanged<int> openTab;

  static ShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellScope>();
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => openTab != oldWidget.openTab;
}
