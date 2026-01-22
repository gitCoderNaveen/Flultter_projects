import 'dart:io';
import 'package:phonebookupdate/core/enums/user_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCompletionPage extends StatefulWidget {
  final UserType userType;

  ProfileCompletionPage({super.key, required this.userType});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  File? _avatarFile;
  bool _loading = false;

  final _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // 📸 Pick avatar
  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  // ☁️ Upload avatar (if exists)
  Future<String?> _uploadAvatar(String userId) async {
    if (_avatarFile == null) return null;

    final path = '$userId/avatar.jpg';

    await supabase.storage
        .from('avatars')
        .upload(
          path,
          _avatarFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  // 💾 Save profile
  Future<void> _submitProfile() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _loading = true);

    try {
      final user = supabase.auth.currentUser!;
      final avatarUrl = await _uploadAvatar(user.id);

      await supabase.from('s_profiles').upsert({
        'id': user.id,
        'user_type': widget.userType.name, // 🔒 enforced
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'avatar_url': avatarUrl,
      });

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final initials = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// Avatar / Initials
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : null,
                  child: _avatarFile == null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Add profile photo (optional)',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitProfile,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
