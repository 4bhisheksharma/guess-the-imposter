import '../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../features/game/controllers/game_controller.dart';
import '../features/game/screens/discussion_screen.dart';
import '../features/game/screens/game_setup_screen.dart';
import '../features/game/screens/results_screen.dart';
import '../features/game/screens/role_reveal_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import 'routes.dart';

class ImposterApp extends StatefulWidget {
  const ImposterApp({super.key});

  @override
  State<ImposterApp> createState() => _ImposterAppState();
}

class _ImposterAppState extends State<ImposterApp> {
  final GameController _gameController = GameController();

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.gameSetup: (context) =>
            GameSetupScreen(controller: _gameController),
        AppRoutes.roleReveal: (context) =>
            RoleRevealScreen(controller: _gameController),
        AppRoutes.discussion: (context) =>
            DiscussionScreen(controller: _gameController),
        AppRoutes.results: (context) =>
            ResultsScreen(controller: _gameController),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}
