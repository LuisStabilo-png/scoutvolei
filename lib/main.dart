// lib/main.dart
import 'package:flutter/material.dart';
import 'Screens/home_page.dart';

void main() {
  runApp(const VolleyScoutApp());
}

class VolleyScoutApp extends StatelessWidget {
  const VolleyScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volley Scout',
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const HomePage(),
    );
  }
}