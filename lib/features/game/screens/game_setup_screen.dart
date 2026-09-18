import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/game_controller.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _playerCount = AppConstants.defaultPlayersCount;
  int _imposterCount = AppConstants.defaultImpostersCount;
  String _selectedCategory = 'Food & Drinks';

  final List<String> _categories = [
    'Food & Drinks',
    'Animals',
    'Movies & TV',
    'Places & Travel',
    'Objects',
  ];

  void _onStartGame() {
    final playerNames = List.generate(_playerCount, (i) => 'Player ${i + 1}');

    widget.controller.startNewGame(
      playerNames: playerNames,
      imposterCount: _imposterCount,
      category: _selectedCategory,
      secretWord: 'Pizza', // Default starter word
    );

    Navigator.pushNamed(context, AppRoutes.roleReveal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildCounterCard(
                      title: 'Players',
                      subtitle: 'Total participants',
                      value: _playerCount,
                      minValue: AppConstants.minPlayers,
                      maxValue: AppConstants.maxPlayers,
                      onChanged: (val) {
                        setState(() {
                          _playerCount = val;
                          if (_imposterCount >= _playerCount) {
                            _imposterCount = _playerCount - 1;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCounterCard(
                      title: 'Imposters',
                      subtitle: 'Hidden deceivers',
                      value: _imposterCount,
                      minValue: AppConstants.minImposters,
                      maxValue: (_playerCount - 1).clamp(1, 5),
                      onChanged: (val) => setState(() => _imposterCount = val),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              dropdownColor: AppColors.surfaceElevated,
                              items: _categories.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                label: 'Start Game',
                icon: Icons.play_arrow_rounded,
                onPressed: _onStartGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required String subtitle,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    value > minValue ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed:
                    value < maxValue ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
