import 'package:flutter/material.dart';
import '../supabase/supabase.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final supabase = SupabaseService.client;
  bool _isEditing = false;
  bool _isLoading = true;

  // Profile fields
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _landlineCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _totalCount = 0;
  int _todayCount = 0;
  int _monthCount = 0;

  int _animatedTotal = 0;
  int _animatedToday = 0;
  int _animatedMonth = 0;

  AnimationController? _counterController;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchCounts();
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      _businessNameController.text = response['business_name'] ?? '';
      _personNameController.text = response['person_name'] ?? '';
      _mobileController.text = response['mobile_number'] ?? '';
      _addressController.text = response['address'] ?? '';
      _cityController.text = response['city'] ?? '';
      _pincodeController.text = response['pincode'] ?? '';
      _landlineController.text = response['landline'] ?? '';
      _landlineCodeController.text = response['landline_code'] ?? '';
      _emailController.text = response['email'] ?? '';
      _passwordController.text = '';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchCounts() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('profiles')
          .select('count, created_at')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        int count = int.tryParse(response['count'] ?? '0') ?? 0;

        final createdAt = DateTime.tryParse(response['created_at'] ?? '');
        final today = DateTime.now();

        int todayCount = (createdAt != null &&
            createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day)
            ? count
            : 0;

        int monthCount = (createdAt != null &&
            createdAt.year == today.year &&
            createdAt.month == today.month)
            ? count
            : 0;

        _totalCount = count;
        _todayCount = todayCount;
        _monthCount = monthCount;

        _animateCounts();
      }
    } catch (e) {
      debugPrint("Error fetching counts: $e");
    }
  }

  void _animateCounts() {
    _counterController?.dispose();
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final totalTween = Tween<int>(begin: 0, end: _totalCount);
    final todayTween = Tween<int>(begin: 0, end: _todayCount);
    final monthTween = Tween<int>(begin: 0, end: _monthCount);

    _counterController!.addListener(() {
      setState(() {
        _animatedTotal = totalTween.evaluate(_counterController!);
        _animatedToday = todayTween.evaluate(_counterController!);
        _animatedMonth = monthTween.evaluate(_counterController!);
      });
    });

    _counterController?.forward();
  }

  Future<void> _addProfileRecord(Map<String, dynamic> newProfile) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Insert new record
      await supabase.from('profiles').insert(newProfile);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Record Added Successfully")),
        );
      }

      // Increment count column for this user
      final profileData = await supabase
          .from('profiles')
          .select('count')
          .eq('id', user.id)
          .maybeSingle();

      int currentCount = 0;
      if (profileData != null && profileData['count'] != null) {
        currentCount = int.tryParse(profileData['count'] as String) ?? 0;
      }

      await supabase
          .from('profiles')
          .update({'count': (currentCount + 1).toString()})
          .eq('id', user.id);

      // Refresh counts with animation
      _fetchCounts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({
      'business_name': _businessNameController.text.trim(),
      'person_name': _personNameController.text.trim(),
      'mobile_number': _mobileController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'landline': _landlineController.text.trim(),
      'landline_code': _landlineCodeController.text.trim(),
      'email': _emailController.text.trim(),
    }).eq('id', user.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updated successfully')),
    );

    setState(() => _isEditing = false);
    _fetchCounts(); // refresh counts in case something changed
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool enabled) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCountTile(String label, int count) {
    final earnings = count * 2;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Count: $count",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Earnings: \₹${earnings}",
                    style: const TextStyle(fontSize: 14, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_businessNameController.text.isNotEmpty
            ? _businessNameController.text
            : _personNameController.text),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Tiles with animated counts and earnings
            _buildCountTile("Total", _animatedTotal),
            _buildCountTile("Today", _animatedToday),
            _buildCountTile("This Month", _animatedMonth),
            const SizedBox(height: 24),
            _buildTextField("Business Name", _businessNameController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Person Name", _personNameController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Mobile Number", _mobileController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Address", _addressController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("City", _cityController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Pincode", _pincodeController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Landline", _landlineController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Landline Code", _landlineCodeController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Email", _emailController, _isEditing),
            const SizedBox(height: 12),
            _buildTextField("Password", _passwordController, _isEditing),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _counterController?.dispose();
    super.dispose();
  }
}
