import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'event_detail_screen.dart';

// Mock data models
class _Event {
  final String title;
  final String time;
  final String host;
  final String category;
  final String? capacity;

  const _Event({
    required this.title,
    required this.time,
    required this.host,
    required this.category,
    this.capacity,
  });
}

const _myEvents = [
  _Event(
    title: 'Jasper Kane',
    time: '10 AM',
    host: 'Colin Sung',
    category: 'Meal',
    capacity: '2/2',
  ),
];

const _feedEvents = [
  _Event(title: 'Central Park', time: '4 PM', host: 'Colin Sung', category: 'Ouside Event'),
  _Event(title: 'NYU Women Tennis', time: '2 PM', host: 'Colin Sung', category: 'NYU Event'),
  _Event(title: 'Whitney Museum of American Art', time: '2 PM', host: 'Colin Sung', category: 'Outside Event'),
];

const _categoryIcons = {
  'Meal': '🍽️',
  'Outside Event': '🗽',
  'NYU event': '📚',
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open add event sheet
        },
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFF57068C), size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day Match',
                    style: GoogleFonts.jersey25(
                      fontSize: 36,
                      color: const Color(0xFF57068C),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF57068C), width: 1.5),
                    ),
                    child: const Icon(Icons.person_outline, color: Color(0xFF4B164C), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // My Event section
              const Text(
                'My Event',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF57068C),
                ),
              ),
              const SizedBox(height: 10),
              ..._myEvents.map((e) => _EventCard(event: e, isMyEvent: true)),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFCCBBDD), thickness: 1),
              const SizedBox(height: 16),

              // My Feed section
              const Text(
                'My Feed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF57068C),
                ),
              ),
              const SizedBox(height: 10),
              ..._feedEvents.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EventCard(event: e, isMyEvent: false),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final _Event event;
  final bool isMyEvent;

  const _EventCard({required this.event, required this.isMyEvent});

  @override
  Widget build(BuildContext context) {
    final bg = isMyEvent ? const Color(0xFFB48FD8) : const Color(0xFF7B4FA8);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EventDetailScreen()),
      ),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${event.title} [${event.time}]',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CategoryBadge(category: event.category),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.host,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              if (event.capacity != null)
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      event.capacity!,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final icon = _categoryIcons[category] ?? '📌';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
