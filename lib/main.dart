import 'package:campus_pal/constants/constants.dart';
import 'package:campus_pal/views/offline_plan/offline_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: geminiApiKey);

  await Hive.initFlutter();
  await Hive.openBox('groceryBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Meal Pal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff0c5f1e)),
        useMaterial3: true,
      ),
      home: SettingsScreen(),
    );
  }
}
