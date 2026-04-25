import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  CollectionReference get _messages => FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.eventId)
      .collection('messages');

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _messages.add({
      'text': text,
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF57068C), size: 24),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Day Match',
                        style: GoogleFonts.jersey25(
                          fontSize: 32,
                          color: const Color(0xFF57068C),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF57068C), width: 1.5),
                    ),
                    child: const Icon(Icons.person_outline, color: Color(0xFF57068C), size: 22),
                  ),
                ],
              ),
            ),

            // Chat partner info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    widget.eventName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Chat area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messages.orderBy('timestamp').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == widget.currentUserId;
                        final text = data['text'] as String? ?? '';
                        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                        final showTime = i == docs.length - 1 ||
                            (docs[i + 1].data() as Map<String, dynamic>)['senderId'] !=
                                data['senderId'];
                        return _MessageBubble(
                          text: text,
                          isMe: isMe,
                          timestamp: showTime ? timestamp : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Input bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  // + button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF57068C),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type Message',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Mic / send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF57068C),
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;

  const _MessageBubble({required this.text, required this.isMe, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE8D8F8) : const Color(0xFFF3EEF8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
            ),
          ),
        ),
        if (timestamp != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 2),
            child: Text(
              '${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')} ${timestamp!.hour >= 12 ? 'PM' : 'AM'}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}