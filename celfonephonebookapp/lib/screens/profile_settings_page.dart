import 'package:flutter/material.dart';
import '../supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        // Populate fields with existing values
        _businessNameController.text = data['business_name'] ?? '';
        _personNameController.text = data['person_name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _cityController.text = data['city'] ?? '';
        _pincodeController.text = data['pincode'] ?? '';
        _mobileController.text = data['mobile_number'] ?? '';
      }
    } catch (e) {
      debugPrint("⚠️ Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      // Update profile data
      await SupabaseService.client.from('profiles').upsert({
        'id': user.id,
        'business_name': _businessNameController.text.trim(),
        'person_name': _personNameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
      });

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      if (context.mounted) {
        _showSuccessDialog();
      }
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
                Navigator.of(context).pop(); // Go back to previous screen
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
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Business Name
              TextFormField(
                controller: _businessNameController,
                decoration:
                const InputDecoration(labelText: "Business Name"),
              ),

              // Person Name
              TextFormField(
                controller: _personNameController,
                decoration:
                const InputDecoration(labelText: "Person Name"),
              ),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),

              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),

              // Pincode
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Pincode"),
              ),

              // Mobile Number
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration:
                const InputDecoration(labelText: "Mobile Number"),
              ),

              // Password
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
