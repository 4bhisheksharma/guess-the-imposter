import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/game_controller.dart';
import '../models/game_session.dart';
import '../widgets/player_card.dart';
import '../widgets/timer_display.dart';

class DiscussionScreen extends StatefulWidget {
  const DiscussionScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;
  String? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.controller.session.discussionDurationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (!_isPaused) {
          setState(() {
            _remainingSeconds--;
            if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
              HapticFeedback.selectionClick();
            } else if (_remainingSeconds == 0) {
              HapticFeedback.heavyImpact();
            }
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() => _isPaused = !_isPaused);
  }

  void _add30Seconds() {
    HapticFeedback.mediumImpact();
    setState(() {
      _remainingSeconds += 30;
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Leave Game?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to end this game and return to the main menu?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Resume Game',
              style: TextStyle(
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.resetGame();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.imposter,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Exit Game',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return shouldQuit ?? false;
  }

  void _onEliminate() {
    if (_selectedPlayerId == null) return;
    HapticFeedback.heavyImpact();
    widget.controller.eliminatePlayer(_selectedPlayerId!);

    if (widget.controller.session.phase == GamePhase.imposterGuess) {
      Navigator.pushReplacementNamed(context, AppRoutes.imposterGuess);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = widget.controller.session;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldQuit = await _onWillPop();
        if (shouldQuit && context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discussion & Vote'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Exit Game',
              icon: FaIcon(
                FontAwesomeIcons.arrowRightFromBracket,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              onPressed: () async {
                final shouldQuit = await _onWillPop();
                if (shouldQuit && context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (route) => false);
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompactScreen = constraints.maxHeight < 640;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    // Timer Widget
                    TimerDisplay(
                      remainingSeconds: _remainingSeconds,
                      totalSeconds: session.discussionDurationSeconds,
                    ),
                    const SizedBox(height: 8),

                    // Quick Timer Controls (Pause/Play & +30s)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _togglePause,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            backgroundColor: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.surfaceLightElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: FaIcon(
                            _isPaused
                                ? FontAwesomeIcons.play
                                : FontAwesomeIcons.pause,
                            size: 11,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            _isPaused ? 'Resume' : 'Pause',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton.icon(
                          onPressed: _add30Seconds,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            backgroundColor: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.surfaceLightElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const FaIcon(
                            FontAwesomeIcons.plus,
                            size: 10,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            '+30s',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_remainingSeconds == 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.imposter.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.imposter.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.triangleExclamation,
                                size: 12, color: AppColors.imposter),
                            SizedBox(width: 6),
                            Text(
                              "Time's Up! Cast your vote now!",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.imposter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: isCompactScreen ? 8 : 14),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Who is acting suspicious?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Select to vote',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Players List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: session.players.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = session.players[index];
                          return PlayerCard(
                            player: player,
                            isSelected: _selectedPlayerId == player.id,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedPlayerId = player.id;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action Button
                    CustomButton(
                      label: _selectedPlayerId != null
                          ? 'Vote to Eliminate'
                          : 'Select a Player to Eliminate',
                      icon: FontAwesomeIcons.gavel,
                      onPressed:
                          _selectedPlayerId != null ? _onEliminate : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
