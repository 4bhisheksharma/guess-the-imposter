/// Core game constants and defaults
class AppConstants {
  AppConstants._();

  static const String appName = 'Find The Imposter';

  // Game defaults
  static const int minPlayers = 3;
  static const int maxPlayers = 20;
  static const int defaultPlayersCount = 4;

  static const int minImposters = 1;
  static const int defaultImpostersCount = 1;

  static const int defaultDiscussionSeconds = 180; // 3 minutes
  static const int minDiscussionSeconds = 60;
  static const int maxDiscussionSeconds = 600;
}
