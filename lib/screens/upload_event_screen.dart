import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';

const _categoryOptions = ['Meal', 'Outside Event', 'NYU Event'];

class UploadEventScreen extends StatefulWidget {
  const UploadEventScreen({super.key});

  @override
  State<UploadEventScreen> createState() => _UploadEventScreenState();
}

class _UploadEventScreenState extends State<UploadEventScreen> {
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _partyController = TextEditingController();
  final _messageController = TextEditingController();
  File? _photo;
  String _selectedCategory = _categoryOptions[0];
  bool _submitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _timeController.dispose();
    _partyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  // Parses strings like "10 AM", "10:30 AM", "14:00", or "2 pm" into a
  // DateTime today (or tomorrow if the slot has already passed). Falls
  // back to one hour from now when the input can't be understood.
  DateTime _parseEndTime(String raw) {
    final now = DateTime.now();
    final s = raw.trim().toUpperCase();
    final match = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?$').firstMatch(s);
    if (match == null) return now.add(const Duration(hours: 1));

    var hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final period = match.group(3);
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour < 12) hour += 12;
    if (hour > 23 || minute > 59) return now.add(const Duration(hours: 1));

    var when = DateTime(now.year, now.month, now.day, hour, minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    return when;
  }

  Future<void> _handlePost() async {
    if (_submitting) return;

    final userId = AuthService().currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again.')),
      );
      return;
    }

    final title = _locationController.text.trim();
    final capacityText = _partyController.text.trim();
    final capacity = int.tryParse(capacityText);
    if (title.isEmpty || capacity == null || capacity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location and a numeric party size are required.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await EventService().createEvent(
        userId: userId,
        title: title,
        category: _selectedCategory,
        endTime: _parseEndTime(_timeController.text),
        capacity: capacity,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1A1A2E)),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Photo picker
                    const Text('Photo', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _photo != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(_photo!, fit: BoxFit.cover),
                                  )
                                : const SizedBox(),
                          ),
                        ),
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: GestureDetector(
                            onTap: _pickPhoto,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.add, color: Color(0xFF57068C), size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _FormField(
                      label: 'Location',
                      child: TextField(
                        controller: _locationController,
                        decoration: _inputDecoration('Jasper Kane, Brooklyn Camp...'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _FormField(
                      label: 'Time',
                      child: TextField(
                        controller: _timeController,
                        decoration: _inputDecoration('10 AM'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _FormField(
                      label: 'Numbers of Party',
                      child: TextField(
                        controller: _partyController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('2'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _FormField(
                      label: 'Category',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _categoryOptions
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedCategory = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _FormField(
                      label: 'Message',
                      child: TextField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: _inputDecoration('').copyWith(
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _handlePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B0FA0),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF8E7BC4),
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Post',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B0FA0), width: 1.5),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}