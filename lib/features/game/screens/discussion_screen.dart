import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/game_controller.dart';
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

  void _onEliminate() {
    if (_selectedPlayerId == null) return;
    HapticFeedback.heavyImpact();
    widget.controller.eliminatePlayer(_selectedPlayerId!);
    Navigator.pushReplacementNamed(context, AppRoutes.results);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = widget.controller.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion & Vote'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              TimerDisplay(
                remainingSeconds: _remainingSeconds,
                totalSeconds: session.discussionDurationSeconds,
              ),
              const SizedBox(height: 10),
              // Compact Quick Timer Controls (Pause/Play & +30s)
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
              const SizedBox(height: 14),
              Text(
                'Who is acting suspicious?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: session.players.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
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
              CustomButton(
                label: 'Vote to Eliminate',
                icon: FontAwesomeIcons.gavel,
                onPressed: _selectedPlayerId != null ? _onEliminate : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
