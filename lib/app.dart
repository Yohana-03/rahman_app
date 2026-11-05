import 'package:finalrahman/app_dependencies.dart';
import 'package:finalrahman/core/api_config.dart';
import 'package:finalrahman/core/network/api_client.dart';
import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:finalrahman/core/theme/theme_controller.dart';
import 'package:finalrahman/features/auth/session_controller.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/ui/login/login_screen.dart';
import 'package:finalrahman/ui/pin/lock_screen.dart';
import 'package:finalrahman/ui/pin/set_pin_screen.dart';
import 'package:finalrahman/ui/shell/main_shell.dart';
import 'package:finalrahman/ui/splash/splash_screen.dart';
import 'package:finalrahman/ui/students/student_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RahmanApp extends StatefulWidget {
  const RahmanApp({
    super.key,
    required this.dependencies,
    this.themeController,
    this.splashDuration = AppTiming.splash,
  });

  final AppDependencies dependencies;
  final ThemeController? themeController;
  final Duration splashDuration;

  @override
  State<RahmanApp> createState() => _RahmanAppState();
}

class _RahmanAppState extends State<RahmanApp> {
  late final ThemeController _theme;
  late final ApiClient _api;
  late final PortalController _portal;
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _theme =
        widget.themeController ??
        ThemeController(widget.dependencies.preferences);
    if (widget.themeController == null) {
      _theme.load();
    }
    _api = ApiClient(
      tokenStore: widget.dependencies.tokenStore,
      onSessionExpired: () => _session.handleSessionExpired(),
    );
    _portal = PortalController(
      api: _api,
      preferences: widget.dependencies.preferences,
    );
    _session = SessionController(
      api: _api,
      tokenStore: widget.dependencies.tokenStore,
      pinStore: widget.dependencies.pinStore,
      preferences: widget.dependencies.preferences,
      portal: _portal,
      splashDuration: widget.splashDuration,
    );
    _session.bootstrap();
  }

  @override
  void dispose() {
    _session.close();
    _portal.close();
    _theme.close();
    _session.dispose();
    _portal.dispose();
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>.value(value: _theme),
        ChangeNotifierProvider<SessionController>.value(value: _session),
        ChangeNotifierProvider<PortalController>.value(value: _portal),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final session = context.watch<SessionController>();
    return MaterialApp(
      title: 'Rahman',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.themeMode,
      home: switch (session.phase) {
        AppPhase.splash => const SplashScreen(),
        AppPhase.login => const LoginScreen(),
        AppPhase.setPin => const SetPinScreen(),
        AppPhase.lock => const LockScreen(),
        AppPhase.selectStudent => const StudentSelectorScreen(),
        AppPhase.portal => const MainShell(),
      },
    );
  }
}
