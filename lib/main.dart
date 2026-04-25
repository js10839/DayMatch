import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const DayMatchApp());
}

class DayMatchApp extends StatelessWidget {
  const DayMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEDE8F5)),
        fontFamily: 'SF Pro Display',
      ),
      home: const SignInScreen(),
    );
  }
}
