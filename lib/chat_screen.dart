import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String routeName;

  const ChatScreen({
    super.key,
    this.otherUserId = '',
    this.otherUserName = 'مسافر',
    this.routeName = 'طريق الرياض ← جدة',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Text(
            widget.otherUserName,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['isMe'] as bool;
                  return Align(
                    alignment: isMe
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF1a1a2e)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1a1a2e),
                    child: IconButton(
                      icon: const Icon(Icons.send,
                          color: Colors.white, size: 18),
                      onPressed: _sendMessage,
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