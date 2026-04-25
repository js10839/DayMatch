import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Photo + gradient (top 55%)
          Column(
            children: [
              Expanded(
                flex: 55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder photo
                    Container(
                      color: const Color(0xFF9E9E9E),
                      child: const Icon(Icons.person, size: 120, color: Colors.white54),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.35, 1.0],
                          colors: [Colors.transparent, Color(0xFF57068C)],
                        ),
                      ),
                    ),

                    // User info (bottom of photo)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: Column(
                        children: [
                          const Text(
                            'Colin Sung',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'COLLEGE OF ART AND SCIENCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('She / her', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const Text('Male', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const Text('Korean', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const Text('2000 / 06/13', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 45, child: SizedBox()),
            ],
          ),

          // Back + CHAT buttons pinned to top of screen
          Positioned(
            top: topPadding + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'CHAT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // White card overlapping bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      // borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Message', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          const SizedBox(height: 6),
                          const Text(
                            'I can meal swipe u',
                            style: TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                          ),
                          const SizedBox(height: 24),
                          Text('Event', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          const SizedBox(height: 6),
                          const Text(
                            'Jasper Kane, Brooklyn Campus',
                            style: TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                          ),
                          const Text(
                            '10:00AM',
                            style: TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                          ),
                          const Spacer(),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD966A8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Join',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}