import 'package:flutter/material.dart';

class WalkieTalkieScreen extends StatefulWidget {
  final String channelName;
  const WalkieTalkieScreen({
    super.key,
    this.channelName = 'riyadh-jeddah',
  });

  @override
  State<WalkieTalkieScreen> createState() => _WalkieTalkieScreenState();
}

class _WalkieTalkieScreenState extends State<WalkieTalkieScreen> {
  bool _isTalking = false;
  bool _isMuted = false;

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0E1A),
          title: const Text('اللاسلكي',
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: _isMuted ? Colors.red : const Color(0xFF00D4AA),
              ),
              onPressed: _toggleMute,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D4AA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('متصل بقناة الطريق',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _isTalking
                    ? const Color(0xFF00D4AA)
                    : const Color(0xFF1E2A3A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Icon(
                _isTalking ? Icons.mic : Icons.mic_off,
                color: _isTalking ? Colors.black : Colors.white54,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isTalking ? 'تتحدث الآن...' : 'اضغط للتحدث',
              style: TextStyle(
                color: _isTalking
                    ? const Color(0xFF00D4AA)
                    : Colors.white54,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTapDown: (_) => setState(() => _isTalking = true),
              onTapUp: (_) => setState(() => _isTalking = false),
              onTapCancel: () => setState(() => _isTalking = false),
              child: Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(bottom: 60),
                decoration: BoxDecoration(
                  color: _isTalking
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFF1E2A3A),
                  shape: BoxShape.circle,
                  boxShadow: _isTalking
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D4AA).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  Icons.mic,
                  color: _isTalking ? Colors.black : Colors.white54,
                  size: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}