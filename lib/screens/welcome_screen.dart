import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Section 1: empty
            const Spacer(),
            // Section 2: logo
            Expanded(
              child: Center(
                child: Text(
                  'Day\nMatch',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jersey25(
                    fontSize: 90,
                    color: const Color(0xFF57068C),
                    height: 1,
                  ),
                ),
              ),
            ),
            // Section 3: welcome
            Expanded(
              child: Center(
                child: Text(
                  'WELCOME',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jersey25(
                    fontSize: 32,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
            ),
            // Section 4: empty
            const Spacer(),
          ],
        ),
      ),
    );
  }
}