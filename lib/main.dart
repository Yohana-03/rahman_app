import 'package:finalrahman/app.dart';
import 'package:finalrahman/app_dependencies.dart';
import 'package:finalrahman/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.production();
  final theme = ThemeController(dependencies.preferences);
  await theme.load();
  runApp(RahmanApp(dependencies: dependencies, themeController: theme));
}
