/// Utility functions for game timers and duration formatting
class TimerHelper {
  TimerHelper._();

  /// Formats seconds into MM:SS format (e.g. 180 -> "03:00")
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}
