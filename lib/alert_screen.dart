import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final List<Map<String, dynamic>> _alertTypes = [
    {'type': 'حادث', 'icon': '🚗', 'color': Color(0xFFE24B4A)},
    {'type': 'غبار', 'icon': '🌫️', 'color': Color(0xFFEF9F27)},
    {'type': 'أمطار', 'icon': '🌧️', 'color': Color(0xFF378ADD)},
    {'type': 'حفريات', 'icon': '🚧', 'color': Color(0xFFEF9F27)},
    {'type': 'وقوف اضطراري', 'icon': '🚨', 'color': Color(0xFFE24B4A)},
    {'type': 'ازدحام', 'icon': '🚦', 'color': Color(0xFFEF9F27)},
    {'type': 'حيوان على الطريق', 'icon': '🐪', 'color': Color(0xFF3ecf8e)},
    {'type': 'طريق مغلق', 'icon': '⛔', 'color': Color(0xFFE24B4A)},
  ];

  String? _selectedType;
  String? _selectedIcon;
  Color? _selectedColor;
  final _detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendAlert() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع التنبيه أولاً')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('alerts').add({
      'type': _selectedType,
      'icon': _selectedIcon,
      'details': _detailsController.text.trim(),
      'lat': 24.7136,
      'lng': 46.6753,
      'route': 'riyadh-jeddah',
      'sender': 'مسافر',
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إرسال التنبيه لجميع المسافرين'),
          backgroundColor: Color(0xFF3ecf8e),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a1a2e),
          title: const Text(
            'إرسال تنبيه',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // التنبيهات الحالية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'التنبيهات الحالية على الطريق',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('alerts')
                          .where('route', isEqualTo: 'riyadh-jeddah')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('✅', style: TextStyle(fontSize: 40)),
                                SizedBox(height: 8),
                                Text(
                                  'لا توجد تنبيهات على هذا الطريق',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                            final docId = snapshot.data!.docs[index].id;
                            return _buildAlertCard(data, docId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // نموذج إرسال تنبيه
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أرسل تنبيهاً جديداً',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // اختيار نوع التنبيه
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _alertTypes.length,
                      itemBuilder: (context, index) {
                        final alert = _alertTypes[index];
                        final isSelected =
                            _selectedType == alert['type'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = alert['type'];
                              _selectedIcon = alert['icon'];
                              _selectedColor = alert['color'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (alert['color'] as Color)
                                      .withOpacity(0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? alert['color'] as Color
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  alert['icon'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alert['type'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? alert['color'] as Color
                                        : Colors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // تفاصيل اختيارية
                  TextField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      hintText: 'تفاصيل إضافية (اختياري)...',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE24B4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _sendAlert,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '⚠️ إرسال التنبيه لجميع المسافرين',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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

  Widget _buildAlertCard(Map<String, dynamic> data, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                data['icon'] ?? '⚠️',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['type'] ?? 'تنبيه',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (data['details'] != null &&
                    data['details'].toString().isNotEmpty)
                  Text(
                    data['details'],
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                Text(
                  'بواسطة: ${data['sender'] ?? 'مسافر'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.grey, size: 18),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('alerts')
                  .doc(docId)
                  .delete();
            },
          ),
        ],
      ),
    );
  }
}