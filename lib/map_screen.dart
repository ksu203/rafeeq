import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'weather_service.dart';
import 'firestore_service.dart';
import 'chat_screen.dart';
import 'alert_screen.dart';
import 'walkie_talkie_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _myLocation = const LatLng(24.7136, 46.6753);

  Map<String, dynamic> _weather = {
    'temp': '--',
    'description': 'جاري التحميل...',
    'icon': '🌤️',
    'humidity': '--',
    'wind': '--',
    'city': 'الرياض',
  };

  bool _isTraveling = false;
  bool _loadingWeather = true;
  String? _myDocId;
  final bool _myDirection = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _loadingWeather = true);
    final weather = await WeatherService.getWeather(
      _myLocation.latitude,
      _myLocation.longitude,
    );
    setState(() {
      _weather = weather;
      _loadingWeather = false;
    });
  }

  Future<void> _toggleTravel() async {
    if (!_isTraveling) {
      final docId = await FirestoreService.addTraveler(
        name: 'أنا',
        avatar: 'أ',
        lat: _myLocation.latitude,
        lng: _myLocation.longitude,
        route: 'riyadh-jeddah',
      );
      setState(() {
        _isTraveling = true;
        _myDocId = docId;
      });
    } else {
      if (_myDocId != null) {
        await FirestoreService.removeTraveler(_myDocId!);
      }
      setState(() {
        _isTraveling = false;
        _myDocId = null;
      });
    }
  }

  String _getTravelerType(Map<String, dynamic> data) {
    final lat = double.tryParse(data['lat'].toString()) ?? 0;
    final direction = data['direction'] ?? true;
    if (direction != _myDirection) return 'opposite';
    if (lat > _myLocation.latitude) return 'ahead';
    return 'behind';
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'ahead': return const Color(0xFF3ecf8e);
      case 'behind': return const Color(0xFFEF9F27);
      case 'opposite': return const Color(0xFFE24B4A);
      default: return const Color(0xFF3ecf8e);
    }
  }

  String _getDirectionLabel(String type, Map<String, dynamic> data) {
    final lat = double.tryParse(data['lat'].toString()) ?? 0;
    final dist = ((lat - _myLocation.latitude).abs() * 111).toStringAsFixed(0);
    switch (type) {
      case 'ahead': return '↑ $dist كم أمامك';
      case 'behind': return '↑ $dist كم خلفك';
      case 'opposite': return '↓ عكس الاتجاه';
      default: return '';
    }
  }

  Color _getDirectionBadgeColor(String type) {
    switch (type) {
      case 'ahead': return const Color(0xFFE1F5EE);
      case 'behind': return const Color(0xFFFAEEDA);
      case 'opposite': return const Color(0xFFFCEBEB);
      default: return Colors.grey.shade100;
    }
  }

  Color _getDirectionTextColor(String type) {
    switch (type) {
      case 'ahead': return const Color(0xFF085041);
      case 'behind': return const Color(0xFF633806);
      case 'opposite': return const Color(0xFF791F1F);
      default: return Colors.grey;
    }
  }

  void _showTravelerCard(Map<String, dynamic> data, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TravelerCard(
        data: data,
        type: type,
        directionLabel: _getDirectionLabel(type, data),
        markerColor: _getMarkerColor(type),
        badgeColor: _getDirectionBadgeColor(type),
        textColor: _getDirectionTextColor(type),
        onChat: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
        onWalkie: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WalkieTalkieScreen()));
        },
      ),
    );
  }

  void _showTravelersList(List<QueryDocumentSnapshot> docs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final same = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return _getTravelerType(data) != 'opposite';
        }).toList();
        final opposite = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return _getTravelerType(data) == 'opposite';
        }).toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _Tab(
                        label: 'نفس اتجاهي (${same.length})',
                        active: true,
                        color: const Color(0xFF3ecf8e),
                      ),
                      const SizedBox(width: 8),
                      _Tab(
                        label: 'عكس الاتجاه (${opposite.length})',
                        active: false,
                        color: const Color(0xFFE24B4A),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...same.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (doc.id == _myDocId) return const SizedBox();
                        final type = _getTravelerType(data);
                        return _TravelerListItem(
                          data: data,
                          type: type,
                          dirLabel: _getDirectionLabel(type, data),
                          markerColor: _getMarkerColor(type),
                          badgeColor: _getDirectionBadgeColor(type),
                          textColor: _getDirectionTextColor(type),
                          onTap: () {
                            Navigator.pop(context);
                            _showTravelerCard(data, type);
                          },
                        );
                      }),
                      if (opposite.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'عكس الاتجاه',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE24B4A),
                            ),
                          ),
                        ),
                        ...opposite.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (doc.id == _myDocId) return const SizedBox();
                          return _TravelerListItem(
                            data: data,
                            type: 'opposite',
                            dirLabel: _getDirectionLabel('opposite', data),
                            markerColor: const Color(0xFFE24B4A),
                            badgeColor: const Color(0xFFFCEBEB),
                            textColor: const Color(0xFF791F1F),
                            onTap: () {
                              Navigator.pop(context);
                              _showTravelerCard(data, 'opposite');
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.getTravelers('riyadh-jeddah'),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final otherDocs = docs.where((d) => d.id != _myDocId).toList();

            List<Marker> markers = [
              Marker(
                point: _myLocation,
                width: 44,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d1117),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3ecf8e), width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
              ...otherDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final lat = double.tryParse(data['lat'].toString()) ?? 0;
                final lng = double.tryParse(data['lng'].toString()) ?? 0;
                final type = _getTravelerType(data);
                final color = _getMarkerColor(type);
                return Marker(
                  point: LatLng(lat, lng),
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => _showTravelerCard(data, type),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              data['avatar'] ?? '؟',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                type == 'ahead' ? '↑' : type == 'behind' ? '↑' : '↓',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ];

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _myLocation,
                    initialZoom: 8,
                    minZoom: 4,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rafeeq.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      bottom: 10,
                      left: 12,
                      right: 12,
                    ),
                    color: const Color(0xFF0d1117),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('رفيق 🛣️',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                _isTraveling ? '🟢 أنت مسافر الآن · نحو جدة' : 'طريق الرياض ← جدة',
                                style: const TextStyle(color: Colors.white60, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        if (!_loadingWeather) ...[
                          Text(_weather['icon'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('${_weather['temp']}°م',
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: _toggleTravel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isTraveling ? const Color(0xFFE24B4A) : const Color(0xFF3ecf8e),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isTraveling ? 'إيقاف' : 'سافر الآن',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _showTravelersList(otherDocs),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, size: 14, color: Color(0xFF0d1117)),
                          const SizedBox(width: 4),
                          Text(
                            '${otherDocs.length} مسافر',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0d1117)),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_up, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 90,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => _mapController.move(_myLocation, 8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.my_location, color: Color(0xFF0d1117), size: 20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FAB(
                        icon: Icons.chat_bubble_rounded,
                        label: 'محادثة',
                        color: const Color(0xFF0d1117),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ChatScreen())),
                      ),
                      const SizedBox(width: 12),
                      _FAB(
                        icon: Icons.radio,
                        label: 'لاسلكي',
                        color: const Color(0xFF00D4AA),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const WalkieTalkieScreen())),
                      ),
                      const SizedBox(width: 12),
                      _FAB(
                        icon: Icons.warning_amber_rounded,
                        label: 'تنبيه',
                        color: const Color(0xFFE24B4A),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AlertScreen())),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FAB extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FAB({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  const _Tab({required this.label, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : Colors.transparent, width: 1.5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? color : Colors.grey)),
    );
  }
}

class _TravelerListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final String type;
  final String dirLabel;
  final Color markerColor;
  final Color badgeColor;
  final Color textColor;
  final VoidCallback onTap;

  const _TravelerListItem({
    required this.data,
    required this.type,
    required this.dirLabel,
    required this.markerColor,
    required this.badgeColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  data['avatar'] ?? '؟',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? 'مسافر',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(dirLabel,
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _TravelerCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String type;
  final String directionLabel;
  final Color markerColor;
  final Color badgeColor;
  final Color textColor;
  final VoidCallback onChat;
  final VoidCallback onWalkie;

  const _TravelerCard({
    required this.data,
    required this.type,
    required this.directionLabel,
    required this.markerColor,
    required this.badgeColor,
    required this.textColor,
    required this.onChat,
    required this.onWalkie,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0d1117),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        data['avatar'] ?? '؟',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'مسافر',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            directionLabel,
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 18)),
                      Text(
                        '${data['rating'] ?? 5}.0',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _InfoChip(label: 'السيارة', value: data['car'] ?? 'غير محدد'),
                      const SizedBox(width: 8),
                      _InfoChip(label: 'اللون', value: data['carColor'] ?? 'غير محدد'),
                      const SizedBox(width: 8),
                      _InfoChip(label: 'اللوحة', value: data['plate'] ?? '---'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onChat,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0d1117),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('محادثة نصية',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: onWalkie,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4AA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('لاسلكي',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_outlined, color: Color(0xFFE24B4A), size: 14),
                          SizedBox(width: 6),
                          Text('إبلاغ عن هذا المستخدم',
                              style: TextStyle(
                                  color: Color(0xFFE24B4A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
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
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}