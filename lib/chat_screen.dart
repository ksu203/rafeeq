import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'السلام عليكم، في أي نقطة أنتم الحين؟',
      'sender': 'خالد',
      'isMe': false,
      'time': '10:12',
      'avatar': 'خ',
    },
    {
      'text': 'وعليكم السلام، عند محطة قريش تقريباً',
      'sender': 'أنا',
      'isMe': true,
      'time': '10:13',
      'avatar': 'أ',
    },
    {
      'text': 'ما في زحمة طريق الحجاج اليوم، ماشية زين',
      'sender': 'سعد',
      'isMe': false,
      'time': '10:15',
      'avatar': 'س',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'sender': 'أنا',
        'isMe': true,
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'avatar': 'أ',
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
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'غرفة الطريق',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'الرياض ← جدة · 3 مسافرين',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          leading: const Icon(Icons.route, color: Color(0xFF3ecf8e)),
        ),
        body: Column(
          children: [
            // تنبيه الطقس
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFAEEDA),
              child: const Row(
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Text(
                    'تنبيه: غبار خفيف بعد 80 كم — قلل السرعة',
                    style: TextStyle(fontSize: 12, color: Color(0xFF854f0b)),
                  ),
                ],
              ),
            ),
            // الرسائل
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessage(msg);
                },
              ),
            ),
            // حقل الكتابة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // زر المايك
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.mic, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  // زر الإرسال
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1a1a2e),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
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

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF3ecf8e).withOpacity(0.2),
              child: Text(
                msg['avatar'],
                style: const TextStyle(fontSize: 12, color: Color(0xFF3ecf8e), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    msg['sender'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF1a1a2e) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    bottomRight: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg['text'],
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                msg['time'],
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}