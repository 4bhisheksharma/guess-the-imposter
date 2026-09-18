import 'dart:async';
import 'package:flutter/material.dart';
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
    widget.controller.eliminatePlayer(_selectedPlayerId!);
    Navigator.pushReplacementNamed(context, AppRoutes.results);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion & Voting'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TimerDisplay(
                remainingSeconds: _remainingSeconds,
                totalSeconds: AppConstants.defaultDiscussionSeconds,
              ),
              const SizedBox(height: 20),
              const Text(
                'Discuss! Who is acting suspicious?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                icon: Icons.how_to_vote_rounded,
                onPressed: _selectedPlayerId != null ? _onEliminate : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
