import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'upload_event_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final me = AuthService().currentUserId;
    final results = await Future.wait([
      EventService().listEvents(),
      if (me != null) EventService().listMyEvents(me) else Future.value(<Event>[]),
    ]);
    final all = results[0];
    final mine = results[1];
    final mineIds = mine.map((e) => e.id).toSet();
    final feed = all.where((e) => !mineIds.contains(e.id)).toList();
    return _HomeData(myEvents: mine, feedEvents: feed);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<void> _openUpload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadEventScreen()),
    );
    if (mounted) await _refresh();
  }

  Future<void> _openDetail(Event event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      floatingActionButton: FloatingActionButton(
        onPressed: _openUpload,
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFF57068C), size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _ScrollableCenter(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ScrollableCenter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load events.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF57068C)),
                    ),
                  ),
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

                    const Text(
                      'My Event',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF57068C)),
                    ),
                    const SizedBox(height: 10),
                    if (data.myEvents.isEmpty)
                      const _EmptyHint(text: "You haven't posted any events yet.")
                    else
                      ...data.myEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EventCard(
                              event: _toCardData(e, showCapacity: true),
                              isMyEvent: true,
                              onTap: () => _openDetail(e),
                            ),
                          )),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFCCBBDD), thickness: 1),
                    const SizedBox(height: 16),

                    const Text(
                      'My Feed',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF57068C)),
                    ),
                    const SizedBox(height: 10),
                    if (data.feedEvents.isEmpty)
                      const _EmptyHint(text: 'No events from others yet.')
                    else
                      ...data.feedEvents.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EventCard(
                              event: _toCardData(e, showCapacity: false),
                              isMyEvent: false,
                              onTap: () => _openDetail(e),
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

EventData _toCardData(Event e, {required bool showCapacity}) {
  return EventData(
    title: e.title,
    time: _formatTime(e.endTime),
    host: 'Host #${e.userId}',
    category: e.category,
    capacity: showCapacity ? '${e.capacity}' : null,
  );
}

String _formatTime(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour;
  final period = h >= 12 ? 'PM' : 'AM';
  final hour12 = h % 12 == 0 ? 12 : h % 12;
  return '$hour12 $period';
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF7B4FA8), fontSize: 14),
      ),
    );
  }
}

class _ScrollableCenter extends StatelessWidget {
  final Widget child;
  const _ScrollableCenter({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}
