import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../supabase/supabase.dart'; // your wrapper

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  String? _userId;
  Map<String, dynamic> _profileData = {};
  String? _editingField; // track which field is in edit mode
  final Map<String, TextEditingController> _controllers = {};

  final ImagePicker _picker = ImagePicker();
  List<String> _uploadedImages = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString("userId");

      if (_userId == null) {
        debugPrint("⚠️ userId not found in SharedPreferences");
        return;
      }

      final data = await SupabaseService.client
          .from("profiles")
          .select()
          .eq("id", _userId as Object)
          .maybeSingle();

      if (data != null) {
        _profileData = data;
        for (final field in _profileData.keys) {
          _controllers[field] =
              TextEditingController(text: _profileData[field]?.toString() ?? "");
        }
        _uploadedImages = List<String>.from(data['product_image'] ?? []);
      }
    } catch (e) {
      debugPrint("⚠️ Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateField(String fieldName) async {
    if (_userId == null) return;

    final newValue = _controllers[fieldName]?.text.trim() ?? "";

    try {
      // Build full row data for upsert to avoid NOT NULL constraint errors
      final upsertData = {
        "id": _userId!,
        "business_name": _profileData["business_name"] ?? "",
        "person_name": _profileData["person_name"] ?? "",
        "mobile_number": _profileData["mobile_number"] ?? "",
        "address": _profileData["address"] ?? "",
        "keywords": _profileData["keywords"] ?? "",
        "description": _profileData["description"] ?? "",
        "city": _profileData["city"] ?? "",
        "pincode": _profileData["pincode"] ?? "",
        "whats_app": _profileData["whats_app"] ?? "",
        "email": _profileData["email"] ?? "",
        "password": _profileData["password"] ?? "",
        // Add other NOT NULL fields if any
      };

      // Update only the edited field
      upsertData[fieldName] = newValue;

      // Upsert the complete row
      await SupabaseService.client.from("profiles").upsert(upsertData);

      setState(() {
        _profileData[fieldName] = newValue;
        _editingField = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$fieldName updated successfully")),
      );
    } catch (e) {
      debugPrint("⚠️ Failed to update $fieldName: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update $fieldName")),
      );
    }
  }







  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || _userId == null) return;

    final file = File(picked.path);
    final fileName = "${DateTime.now().millisecondsSinceEpoch}_${picked.name}";

    try {
      final storagePath = "product_images/$_userId/$fileName";
      await SupabaseService.client.storage
          .from("uploads") // bucket name in Supabase
          .upload(storagePath, file);

      final publicUrl = SupabaseService.client.storage
          .from("uploads")
          .getPublicUrl(storagePath);

      _uploadedImages.add(publicUrl);

      // update array column in profiles
      await SupabaseService.client.from("profiles").update({
        "product_image": _uploadedImages,
      }).eq("id", _userId!);

      setState(() {});
    } catch (e) {
      debugPrint("⚠️ Image upload failed: $e");
    }
  }

  Widget _buildField(String label, String fieldName) {
    // Ensure controller exists
    if (!_controllers.containsKey(fieldName)) {
      _controllers[fieldName] =
          TextEditingController(text: _profileData[fieldName]?.toString() ?? "");
    }

    final controller = _controllers[fieldName]!;
    final value = controller.text;
    final displayValue = value.isEmpty ? "<empty>" : value;
    final isEditing = _editingField == fieldName;

    return ListTile(
      title: isEditing
          ? TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter $label",
        ),
        onSubmitted: (_) {
          _updateField(fieldName); // Save when Enter is pressed
        },
      )
          : Text("$label: $displayValue"),
      trailing: IconButton(
        icon: Icon(
          isEditing ? Icons.check : Icons.edit,
          color: isEditing ? Colors.green : Colors.blue,
        ),
        onPressed: () {
          if (isEditing) {
            _updateField(fieldName); // Save edited value
          } else {
            setState(() => _editingField = fieldName);
          }
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            _buildField("Business Name", "business_name"),
            _buildField("Person Name", "person_name"),
            // _buildField("Mobile Number", "mobile_number"),
            _buildField("Address", "address"),
            _buildField("Keywords", "keywords"),
            // _buildField("Description", "description"),
            _buildField("City", "city"),
            _buildField("Pincode", "pincode"),
            _buildField("WhatsApp", "whats_app"),
            _buildField("Email", "email"),
            // _buildField("Password", "password"),
            // const Divider(),
            // const Text("Product Images",
            //     style:
            //     TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: [
            //     ..._uploadedImages.map(
            //           (url) => ClipRRect(
            //         borderRadius: BorderRadius.circular(8),
            //         child: Image.network(url,
            //             width: 100, height: 100, fit: BoxFit.cover),
            //       ),
            //     ),
            //     GestureDetector(
            //       onTap: _pickAndUploadImage,
            //       child: Container(
            //         width: 100,
            //         height: 100,
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.grey),
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: const Icon(Icons.add_a_photo),
            //       ),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
