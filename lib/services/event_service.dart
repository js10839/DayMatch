import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class Event {
  final int id;
  final int userId;
  final String title;
  final String category;
  final DateTime endTime;
  final int capacity;
  final DateTime? uploadTime;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.endTime,
    required this.capacity,
    this.uploadTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['event_id'] as int,
        userId: json['user_id'] as int,
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        endTime: DateTime.parse(json['end_time'] as String),
        capacity: (json['capacity'] as num).toInt(),
        uploadTime: json['upload_time'] != null
            ? DateTime.parse(json['upload_time'] as String)
            : null,
      );
}

class Participant {
  final int userId;
  final String? name;
  final String? email;
  final String? college;

  Participant({required this.userId, this.name, this.email, this.college});

  factory Participant.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? {};
    return Participant(
      userId: json['user_id'] as int,
      name: user['name'] as String?,
      email: user['email'] as String?,
      college: user['college'] as String?,
    );
  }
}

class EventService {
  EventService._();
  static final EventService _instance = EventService._();
  factory EventService() => _instance;

  String get _baseUrl => AuthService().baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Event>> listEvents() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events'),
      headers: await _headers(),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to load events.');
    }
    final list = body['events'] as List<dynamic>;
    return list
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Event>> listMyEvents(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events/my/$userId'),
      headers: await _headers(),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to load my events.');
    }
    final list = body['events'] as List<dynamic>;
    return list
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Event> getEvent(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events/$id'),
      headers: await _headers(),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to load event.');
    }
    return Event.fromJson(body['event'] as Map<String, dynamic>);
  }

  Future<Event> createEvent({
    required int userId,
    required String title,
    required String category,
    required DateTime endTime,
    required int capacity,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events'),
      headers: await _headers(),
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'category': category,
        'end_time': endTime.toUtc().toIso8601String(),
        'capacity': capacity,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw Exception(body['message'] ?? 'Failed to create event.');
    }
    return Event.fromJson(body['event'] as Map<String, dynamic>);
  }

  Future<void> joinEvent(int eventId, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events/$eventId/join'),
      headers: await _headers(),
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode == 201) return;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['message'] ?? 'Failed to join event.');
  }

  Future<void> leaveEvent(int eventId, int userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/events/$eventId/join'),
      headers: await _headers(),
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode == 200) return;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['message'] ?? 'Failed to leave event.');
  }

  Future<List<Participant>> listParticipants(int eventId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events/$eventId/participants'),
      headers: await _headers(),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to load participants.');
    }
    final list = body['participants'] as List<dynamic>;
    return list
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
