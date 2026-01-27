import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:celfonephonebookapp/core/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  File? _pickedImage;
  String? _avatarUrl;

  bool _loading = true;
  bool _saving = false;

  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔹 Load profile & prefill
  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();

    if (profile != null) {
      _nameController.text = profile['full_name'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _cityController.text = profile['city'] ?? '';
      _avatarUrl = profile['avatar_url'];
    }

    if (mounted) setState(() => _loading = false);
  }

  // 📸 Pick image
  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  // ☁️ Upload avatar to Supabase Storage
  Future<String?> _uploadAvatar() async {
    if (_pickedImage == null) return _avatarUrl;

    final user = _supabase.auth.currentUser!;
    final path = '${user.id}/avatar.jpg';

    await _supabase.storage.from('avatars').upload(
          path,
          _pickedImage!,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  // 💾 Save profile (text + avatar)
  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    try {
      final avatarUrl = await _uploadAvatar();

      await ProfileService.updateProfile({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'avatar_url': avatarUrl,
      });

      if (!mounted) return;

      setState(() {
        _avatarUrl = avatarUrl;
        _pickedImage = null;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String initials = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              /// Avatar
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_avatarUrl != null
                            ? NetworkImage(_avatarUrl!) as ImageProvider
                            : null),
                    child: (_pickedImage == null && _avatarUrl == null)
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 32),

              _field(_nameController, 'Full Name'),
              _field(_phoneController, 'Phone Number'),
              _field(_cityController, 'City'),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
