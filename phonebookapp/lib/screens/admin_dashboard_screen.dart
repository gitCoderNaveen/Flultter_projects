import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _auth = AuthService();
  final _client = Supabase.instance.client;

  List<Map<String, dynamic>> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    final res = await _client
        .from('profiles')
        .select('id, mobile_number, business_name, business_prefix, is_admin, created_at')
        .order('created_at', ascending: false)
        .execute();
    if (res.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching users: ${res.error!.message}')));
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _users = List<Map<String, dynamic>>.from(res.data ?? []);
      _loading = false;
    });
  }

  Future<void> _toggleAdmin(String userId, bool current) async {
    final res = await _client.from('profiles').update({'is_admin': !current}).eq('id', userId).execute();
    if (res.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating user: ${res.error!.message}')));
      return;
    }
    await _fetchUsers();
  }

  Future<void> _deleteUser(String userId) async {
    // Deleting from auth.users requires Supabase Admin key or server function — this UI will remove profile only.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete user profile?'),
        content: Text('This will delete the profile row only. To fully remove auth account, use Supabase Dashboard or server-side admin function.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final res = await _client.from('profiles').delete().eq('id', userId).execute();
    if (res.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting profile: ${res.error!.message}')));
      return;
    }
    await _fetchUsers();
  }

  Future<void> _viewUserContent(String userId) async {
    // Fetch root_keywords and root_products for the user
    final rkResp = await _client.from('root_keywords').select('id, keywords, created_at').eq('user_id', userId).execute();
    final rpResp = await _client.from('root_products').select('id, category, created_at').eq('user_id', userId).execute();

    final rk = rkResp.error == null ? List<Map<String, dynamic>>.from(rkResp.data ?? []) : [];
    final rp = rpResp.error == null ? List<Map<String, dynamic>>.from(rpResp.data ?? []) : [];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('User Content'),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Root Keywords', style: TextStyle(fontWeight: FontWeight.bold)),
                if (rk.isEmpty) Text('— none'),
                for (var k in rk) ListTile(title: Text(k['keywords'] ?? ''), subtitle: Text(k['created_at'] ?? '')),

                SizedBox(height: 12),
                Text('Root Products', style: TextStyle(fontWeight: FontWeight.bold)),
                if (rp.isEmpty) Text('— none'),
                for (var p in rp) ListTile(title: Text(p['category'] ?? ''), subtitle: Text(p['created_at'] ?? '')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final id = user['id'] as String;
    final mobile = user['mobile_number'] ?? '';
    final name = user['business_name'] ?? '';
    final prefix = user['business_prefix'] ?? '';
    final isAdmin = (user['is_admin'] ?? false) as bool;

    return Card(
      child: ListTile(
        title: Text(mobile),
        subtitle: Text('$name ${prefix.isNotEmpty ? '• $prefix' : ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility),
              tooltip: 'View content',
              onPressed: () => _viewUserContent(id),
            ),
            Switch(
              value: isAdmin,
              onChanged: (val) => _toggleAdmin(id, isAdmin),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete profile',
              onPressed: () => _deleteUser(id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchUsers),
          IconButton(icon: Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchUsers,
        child: _users.isEmpty
            ? ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [SizedBox(height: 200), Center(child: Text('No users found'))],
        )
            : ListView.builder(
          itemCount: _users.length,
          itemBuilder: (_, i) => _buildUserTile(_users[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        tooltip: 'Create user (manual)',
        onPressed: () => _showCreateUserDialog(),
      ),
    );
  }

  Future<void> _showCreateUserDialog() async {
    final mobileCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Create user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: mobileCtrl, decoration: InputDecoration(labelText: 'Mobile (+countrycode...)')),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Business name (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Create'),
          ),
        ],
      ),
    );

    if (created != true) return;

    final mobile = mobileCtrl.text.trim();
    final password = passCtrl.text;
    final business = nameCtrl.text.trim();

    try {
      // create a synthetic email and sign up via auth (same pattern as AuthService)
      final email = '${mobile.replaceAll(' ', '')}@phone.local';
      final resp = await _client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          userMetadata: {'mobile_number': mobile},
        ),
      );

      if (resp.user != null) {
        // create profile row
        await _client.from('profiles').insert({
          'id': resp.user!.id,
          'business_name': business,
          'mobile_number': mobile,
        }).execute();
        await _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User created')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create user')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating user: $e')));
    }
  }
}
