import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
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
  String? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = AppConstants.defaultDiscussionSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
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
                totalSeconds: AppConstants.defaultDiscussionSeconds,
              ),
              const SizedBox(height: 18),
              Text(
                'Who is acting suspicious?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : Colors.black87,
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
