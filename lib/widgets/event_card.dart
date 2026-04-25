import 'package:flutter/material.dart';

const categoryIcons = {
  'Meal': '🍽️',
  'Outside Event': '🗽',
  'NYU Event': '📚',
};

class EventData {
  final String title;
  final String time;
  final String host;
  final String category;
  final String? capacity;

  const EventData({
    required this.title,
    required this.time,
    required this.host,
    required this.category,
    this.capacity,
  });
}

class EventCard extends StatelessWidget {
  final EventData event;
  final bool isMyEvent;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.isMyEvent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMyEvent ? const Color(0xFFB48FD8) : const Color(0xFF7B4FA8);

    return GestureDetector(
      onTap: onTap,
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
    final icon = categoryIcons[category] ?? '📌';
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