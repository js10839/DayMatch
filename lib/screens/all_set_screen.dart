import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllSetScreen extends StatefulWidget {
  final String personName;
  const AllSetScreen({super.key, required this.personName});

  @override
  State<AllSetScreen> createState() => _AllSetScreenState();
}

class _AllSetScreenState extends State<AllSetScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: Stack(
        children: [
          // Scattered clovers
          const Positioned(top: 48, left: 60, child: _Clover(size: 36)),
          const Positioned(top: 80, right: 70, child: _Clover(size: 22)),
          const Positioned(top: 130, left: 160, child: _Clover(size: 18)),
          const Positioned(top: 155, right: 130, child: _Clover(size: 16)),
          const Positioned(top: 300, left: 28, child: _Clover(size: 42)),
          const Positioned(top: 500, left: 80, child: _Clover(size: 22)),
          const Positioned(top: 480, right: 50, child: _Clover(size: 28)),
          const Positioned(top: 560, left: 200, child: _Clover(size: 20)),
          const Positioned(top: 620, left: 50, child: _Clover(size: 32)),
          const Positioned(top: 650, right: 100, child: _Clover(size: 18)),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Verified badge
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 100,
                    color: Color(0xFF3B0098),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "You're all set!",
                  style: GoogleFonts.jersey25(
                    fontSize: 26,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Meet ${widget.personName}!',
                  style: GoogleFonts.jersey25(
                    fontSize: 26,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Clover extends StatelessWidget {
  final double size;
  const _Clover({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CloverPainter(),
    );
  }
}

class _CloverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB08ED4);
    final r = size.width / 4;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 4 petals
    canvas.drawCircle(Offset(cx, cy - r), r, paint);
    canvas.drawCircle(Offset(cx, cy + r), r, paint);
    canvas.drawCircle(Offset(cx - r, cy), r, paint);
    canvas.drawCircle(Offset(cx + r, cy), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}