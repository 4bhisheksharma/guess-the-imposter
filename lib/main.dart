import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/word_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-load word database into memory before app starts to ensure instant availability
  await WordService.instance.loadWords();
  runApp(const ImposterApp());
}
