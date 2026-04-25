import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'upload_event_screen.dart';
import 'profile_screen.dart';

const _myEvents = [
  EventData(
    title: 'Jasper Kane',
    time: '10 AM',
    host: 'Colin Sung',
    category: 'Meal',
    capacity: '2/2',
  ),
];

const _feedEvents = [
  EventData(title: 'Central Park', time: '4 PM', host: 'Colin Sung', category: 'Outside Event'),
  EventData(title: 'NYU Women Tennis', time: '2 PM', host: 'Colin Sung', category: 'NYU Event'),
  EventData(title: 'Whitney Museum of American Art', time: '2 PM', host: 'Colin Sung', category: 'Outside Event'),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadEventScreen()),
        ),
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
                    style: GoogleFonts.jersey25(fontSize: 36, color: const Color(0xFF57068C)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF57068C), width: 1.5),
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFF4B164C), size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // My Event section
              const Text(
                'My Event',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF57068C)),
              ),
              const SizedBox(height: 10),
              ..._myEvents.map((e) => EventCard(
                    event: e,
                    isMyEvent: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EventDetailScreen()),
                    ),
                  )),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFCCBBDD), thickness: 1),
              const SizedBox(height: 16),

              // My Feed section
              const Text(
                'My Feed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF57068C)),
              ),
              const SizedBox(height: 10),
              ..._feedEvents.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EventCard(
                      event: e,
                      isMyEvent: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventDetailScreen()),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}