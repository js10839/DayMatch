import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllSetScreen extends StatefulWidget {
  const AllSetScreen({super.key});

  @override
  State<AllSetScreen> createState() => _AllSetScreenState();
}

class _AllSetScreenState extends State<AllSetScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: Center(
        child: Text(
          "You're all set!",
          style: GoogleFonts.jersey25(
            fontSize: 28,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }
}