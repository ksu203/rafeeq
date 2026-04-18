import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String> addTraveler({
    required String name,
    required String avatar,
    required double lat,
    required double lng,
    required String route,
  }) async {
    final doc = await _db.collection('travelers').add({
      'name': name,
      'avatar': avatar,
      'lat': lat,
      'lng': lng,
      'route': route,
      'distance': 'على الطريق',
      'rating': 5,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<void> removeTraveler(String docId) async {
    await _db.collection('travelers').doc(docId).delete();
  }

  static Stream<QuerySnapshot> getTravelers(String route) {
    return _db
        .collection('travelers')
        .where('route', isEqualTo: route)
        .where('active', isEqualTo: true)
        .snapshots();
  }
}