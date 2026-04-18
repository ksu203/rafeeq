import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _plateController = TextEditingController();

  bool _showPlate = true;
  bool _showCar = true;
  bool _isLoading = false;
  String? _photoUrl;
  File? _pickedImage;

  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();
    if (doc.exists) {
      final d = doc.data()!;
      _nameController.text = d['name'] ?? '';
      _carModelController.text = d['carModel'] ?? '';
      _carColorController.text = d['carColor'] ?? '';
      _plateController.text = d['plate'] ?? '';
      setState(() {
        _showPlate = d['showPlate'] ?? true;
        _showCar = d['showCar'] ?? true;
        _photoUrl = d['photoUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 400,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadPhoto() async {
    if (_pickedImage == null) return _photoUrl;
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos/$_uid.jpg');
    await ref.putFile(_pickedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uploadedUrl = await _uploadPhoto();

      await FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'name': _nameController.text.trim(),
        'carModel': _carModelController.text.trim(),
        'carColor': _carColorController.text.trim(),
        'plate': _plateController.text.trim().toUpperCase(),
        'showPlate': _showPlate,
        'showCar': _showCar,
        'photoUrl': uploadedUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حفظ الملف الشخصي'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: const Text('الملف الشخصي',
            style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('حفظ',
                  style: TextStyle(color: Color(0xFF00D4AA), fontSize: 16,
                      fontFamily: 'Cairo')),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── صورة الملف الشخصي ──
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF1E2A3A),
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (_photoUrl != null
                              ? NetworkImage(_photoUrl!) as ImageProvider
                              : null),
                      child: (_pickedImage == null && _photoUrl == null)
                          ? const Icon(Icons.person, size: 55,
                              color: Color(0xFF00D4AA))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00D4AA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── معلومات شخصية ──
            _sectionTitle('المعلومات الشخصية'),
            const SizedBox(height: 12),
            _buildField(
              controller: _nameController,
              label: 'الاسم',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 28),

            // ── بيانات السيارة ──
            _sectionTitle('بيانات السيارة'),
            const SizedBox(height: 12),
            _buildField(
              controller: _carModelController,
              label: 'نوع السيارة (مثال: تويوتا كامري)',
              icon: Icons.directions_car_outlined,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _carColorController,
              label: 'لون السيارة',
              icon: Icons.color_lens_outlined,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _plateController,
              label: 'رقم اللوحة',
              icon: Icons.pin_outlined,
              hint: 'ABC 1234',
            ),
            const SizedBox(height: 28),

            // ── إعدادات الخصوصية ──
            _sectionTitle('الخصوصية'),
            const SizedBox(height: 12),
            _privacyToggle(
              title: 'إظهار رقم اللوحة للمستخدمين',
              subtitle: 'يستطيع المسافرون القريبون رؤية لوحتك',
              value: _showPlate,
              onChanged: (v) => setState(() => _showPlate = v),
            ),
            const SizedBox(height: 8),
            _privacyToggle(
              title: 'إظهار بيانات السيارة',
              subtitle: 'نوع ولون السيارة مرئيان للآخرين',
              value: _showCar,
              onChanged: (v) => setState(() => _showCar = v),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          color: Color(0xFF00D4AA),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Cairo'),
          hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Cairo'),
          prefixIcon: Icon(icon, color: const Color(0xFF00D4AA)),
          filled: true,
          fillColor: const Color(0xFF1E2A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 1.5),
          ),
          errorStyle: const TextStyle(fontFamily: 'Cairo'),
        ),
      );

  Widget _privacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF00D4AA),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Cairo')),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12,
                          fontFamily: 'Cairo')),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _plateController.dispose();
    super.dispose();
  }
}