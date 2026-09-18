import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/game/controllers/game_controller.dart';
import '../features/game/screens/discussion_screen.dart';
import '../features/game/screens/game_setup_screen.dart';
import '../features/game/screens/results_screen.dart';
import '../features/game/screens/role_reveal_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/settings/controllers/settings_controller.dart';
import '../features/settings/screens/settings_screen.dart';
import 'routes.dart';

class ImposterApp extends StatefulWidget {
  const ImposterApp({super.key});

  @override
  State<ImposterApp> createState() => _ImposterAppState();
}

class _ImposterAppState extends State<ImposterApp> {
  final GameController _gameController = GameController();
  final SettingsController _settingsController = SettingsController();

  @override
  void dispose() {
    _gameController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settingsController.themeMode,
          initialRoute: AppRoutes.home,
          routes: {
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.gameSetup: (context) => GameSetupScreen(
                  controller: _gameController,
                  settingsController: _settingsController,
                ),
            AppRoutes.roleReveal: (context) =>
                RoleRevealScreen(controller: _gameController),
            AppRoutes.discussion: (context) =>
                DiscussionScreen(controller: _gameController),
            AppRoutes.results: (context) =>
                ResultsScreen(controller: _gameController),
            AppRoutes.settings: (context) =>
                SettingsScreen(controller: _settingsController),
          },
        );
      },
    );
  }
}
