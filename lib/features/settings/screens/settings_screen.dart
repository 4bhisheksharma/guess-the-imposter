import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: SwitchListTile(
                title: const Text(
                  'Sound Effects',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Game sound cues and timer beeps'),
                value: _soundEnabled,
                onChanged: (val) => setState(() => _soundEnabled = val),
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: SwitchListTile(
                title: const Text(
                  'Haptic Feedback',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Vibrate on role reveal and alerts'),
                value: _vibrationEnabled,
                onChanged: (val) => setState(() => _vibrationEnabled = val),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                '${AppConstants.appName} v0.1.0',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
