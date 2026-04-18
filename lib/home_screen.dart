import 'alert_screen.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTraveling = false;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _travelers = [
    {
      'name': 'أ. خالد العمري',
      'distance': '18 كم أمامك',
      'rating': 5,
      'avatar': 'خ',
      'color': Color(0xFF3ecf8e),
    },
    {
      'name': 'م. سعد الحربي',
      'distance': '7 كم خلفك',
      'rating': 4,
      'avatar': 'س',
      'color': Color(0xFFEF9F27),
    },
    {
      'name': 'ن. الشهري',
      'distance': '42 كم خلفك',
      'rating': 5,
      'avatar': 'ن',
      'color': Color(0xFF378ADD),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'رفيق 🛣️',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _isTraveling ? '🟢 أنت مسافر الآن' : 'طريق الرياض ← جدة',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTraveling ? Colors.red : const Color(0xFF3ecf8e),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                onPressed: () => setState(() => _isTraveling = !_isTraveling),
                child: Text(_isTraveling ? 'إيقاف السفر' : 'وضع السفر', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFFE8F4F0),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 12,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 84),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.route, size: 60, color: Color(0xFF3ecf8e)),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        children: [
                          Text('🌤️ صافٍ · 38°', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'المسافرون على نفس طريقك (${_travelers.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _travelers.length,
                      itemBuilder: (context, index) {
                        final t = _travelers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: t['color'].withOpacity(0.2),
                                child: Text(
                                  t['avatar'],
                                  style: TextStyle(color: t['color'], fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(t['distance'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        Icons.star,
                                        size: 14,
                                        color: i < t['rating'] ? const Color(0xFFEF9F27) : Colors.grey.shade300,
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1a1a2e),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                                  );
                                },
                                child: const Text('محادثة', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
  setState(() => _currentIndex = i);
 if (i == 0) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MapScreen()),
  );
} else if (i == 1) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ChatScreen()),
  );
} else if (i == 2) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AlertScreen()),
  );
}
},
          selectedItemColor: const Color(0xFF1a1a2e),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'الطريق'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'المحادثة'),
            BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'طوارئ'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'التقييم'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}