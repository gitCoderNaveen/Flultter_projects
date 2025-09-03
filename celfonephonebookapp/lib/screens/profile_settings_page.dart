import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId == null) return;

      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _businessNameController.text = data['business_name'] ?? '';
        _personNameController.text = data['person_name'] ?? '';
        _doorNoController.text = data['door_no'] ?? '';
        _streetController.text = data['street'] ?? '';
        _areaController.text = data['area'] ?? '';
        _cityController.text = data['city'] ?? '';
        _pincodeController.text = data['pincode'] ?? '';
        _mobileController.text = data['mobile_number'] ?? '';
      }
    } catch (e) {
      debugPrint("⚠️ Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false); // Make sure to hide the loader
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId == null) return;

      await SupabaseService.client.from('profiles').upsert({
        'id': userId,
        'business_name': _businessNameController.text.trim(),
        'person_name': _personNameController.text.trim(),
        'door_no': _doorNoController.text.trim(),
        'street': _streetController.text.trim(),
        'area': _areaController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
      });

      if (_passwordController.text.isNotEmpty) {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      if (context.mounted) _showSuccessDialog();
    } catch (e) {
      debugPrint("⚠️ Error updating profile: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Profile updated successfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Settings")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: "Business Name"),
              ),
              TextFormField(
                controller: _personNameController,
                decoration: const InputDecoration(labelText: "Person Name"),
              ),
              // Address Row: Door No, Street, Area
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _doorNoController,
                      decoration: const InputDecoration(labelText: "Door No"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(labelText: "Street"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _areaController,
                      decoration: const InputDecoration(labelText: "Area"),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Pincode"),
              ),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Mobile Number"),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "New Password (Leave blank to keep)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
