import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import 'all_set_screen.dart';
import 'chat_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<List<Participant>> _participantsFuture;
  bool _joined = false;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _participantsFuture = EventService().listParticipants(widget.event.id);
    _participantsFuture.then((list) {
      final me = AuthService().currentUserId;
      if (me != null && mounted) {
        setState(() => _joined = list.any((p) => p.userId == me));
      }
    }).catchError((_) {});
  }

  Future<void> _handleJoin() async {
    if (_joining || _joined) return;
    final userId = AuthService().currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again.')),
      );
      return;
    }

    setState(() => _joining = true);
    try {
      await EventService().joinEvent(widget.event.id, userId);
      if (!mounted) return;
      setState(() {
        _joined = true;
        _participantsFuture = EventService().listParticipants(widget.event.id);
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllSetScreen(personName: 'Host #${widget.event.userId}'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'AM' : 'PM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final event = widget.event;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: const Color(0xFF9E9E9E),
                      child: const Icon(Icons.person, size: 120, color: Colors.white54),
                    ),
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
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: Column(
                        children: [
                          Text(
                            'Host #${event.userId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 45, child: SizedBox()),
            ],
          ),

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
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final me = AuthService().currentUser;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            eventId: 'event-${event.id}',
                            eventName: event.title,
                            currentUserId: '${me?['user_id'] ?? 'me'}',
                            currentUserName: (me?['name'] as String?) ?? 'Me',
                          ),
                        ),
                      );
                    },
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
                ),
              ],
            ),
          ),

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
                    decoration: BoxDecoration(color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Event', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          const SizedBox(height: 6),
                          Text(
                            event.title,
                            style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(event.endTime),
                            style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                          ),
                          const SizedBox(height: 24),
                          Text('Capacity', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          const SizedBox(height: 6),
                          FutureBuilder<List<Participant>>(
                            future: _participantsFuture,
                            builder: (context, snapshot) {
                              final count = snapshot.data?.length;
                              final label = count != null
                                  ? '$count / ${event.capacity}'
                                  : '— / ${event.capacity}';
                              return Text(
                                label,
                                style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                              );
                            },
                          ),
                          const Spacer(),
                          Center(
                            child: ElevatedButton(
                              onPressed: (_joined || _joining) ? null : _handleJoin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _joined
                                    ? Colors.grey[300]
                                    : const Color(0xFFD966A8),
                                foregroundColor: _joined ? Colors.grey : Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                disabledForegroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: _joining
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _joined ? 'Joined!' : 'Join',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
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
