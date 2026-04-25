import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  void _handlePost() {
    // TODO: send event data to backend
    Navigator.pop(context);
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
                        onPressed: _handlePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B0FA0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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