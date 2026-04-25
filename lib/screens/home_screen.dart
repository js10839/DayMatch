import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import 'event_detail_screen.dart';
import 'upload_event_screen.dart';

const _categoryIcons = {
  'Meal': '🍽️',
  'Outside Event': '🗽',
  'NYU Event': '📚',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_HomeData> _loadData() async {
    final userId = AuthService().currentUserId;
    final all = await EventService().listEvents();
    final mine = userId != null
        ? all.where((e) => e.userId == userId).toList()
        : <Event>[];
    final feed = userId != null
        ? all.where((e) => e.userId != userId).toList()
        : all;
    return _HomeData(myEvents: mine, feedEvents: feed);
  }

  void _refresh() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadEventScreen()),
          );
          if (mounted) _refresh();
        },
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFF57068C), size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: FutureBuilder<_HomeData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B0FA0)),
                );
              }
              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Text(
                        'Failed to load events.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF1A1A2E)),
                      ),
                    ),
                  ],
                );
              }
              final data = snapshot.data!;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            border: Border.all(
                              color: const Color(0xFF57068C),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF4B164C),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'My Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF57068C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (data.myEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No events created yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...data.myEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EventCard(
                              event: e,
                              isMyEvent: true,
                              onChanged: _refresh,
                            ),
                          )),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFCCBBDD), thickness: 1),
                    const SizedBox(height: 16),

                    const Text(
                      'My Feed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF57068C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (data.feedEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No events yet. Pull to refresh.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...data.feedEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EventCard(
                              event: e,
                              isMyEvent: false,
                              onChanged: _refresh,
                            ),
                          )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  final List<Event> myEvents;
  final List<Event> feedEvents;
  _HomeData({required this.myEvents, required this.feedEvents});
}

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isMyEvent;
  final VoidCallback onChanged;

  const _EventCard({
    required this.event,
    required this.isMyEvent,
    required this.onChanged,
  });

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'AM' : 'PM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final bg = isMyEvent ? const Color(0xFFB48FD8) : const Color(0xFF7B4FA8);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        );
        onChanged();
      },
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
                    '${event.title} [${_formatTime(event.endTime)}]',
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
                  'Host #${event.userId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${event.capacity}',
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
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            category.isEmpty ? 'Event' : category,
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
