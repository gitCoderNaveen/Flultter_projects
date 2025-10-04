import 'package:flutter/material.dart';
import '../supabase/supabase.dart'; // Make sure this points to your SupabaseService

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int totalUsers = 0;
  int totalBusinesses = 0;
  int totalPeople = 0;
  int totalPrime = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);

    try {
      final client = SupabaseService.client;

      // Fetch all rows safely
      final totalUsersResponse = await client.from('profiles').select('id');
      final totalBusinessesResponse =
      await client.from('profiles').select('id').eq('user_type', 'business');
      final totalPeopleResponse =
      await client.from('profiles').select('id').eq('user_type', 'person');
      final totalPrimeResponse =
      await client.from('profiles').select('id').eq('is_prime', true);

      // Count locally and safely
      setState(() {
        totalUsers = (totalUsersResponse as List?)?.length ?? 0;
        totalBusinesses = (totalBusinessesResponse as List?)?.length ?? 0;
        totalPeople = (totalPeopleResponse as List?)?.length ?? 0;
        totalPrime = (totalPrimeResponse as List?)?.length ?? 0;
        _isLoading = false;
      });

      // Debug logs to see what data is fetched
      debugPrint("All Users: $totalUsersResponse");
      debugPrint("Businesses: $totalBusinessesResponse");
      debugPrint("People: $totalPeopleResponse");
      debugPrint("Prime Users: $totalPrimeResponse");
    } catch (e) {
      debugPrint("⚠️ Error fetching stats: $e");
      setState(() => _isLoading = false);
    }
  }



  Widget _buildStatTile(String title, int value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value),
                  duration: const Duration(seconds: 2),
                  builder: (context, val, _) => Text(
                    "$val",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatTile(
                "Total Users", totalUsers, Colors.blue, Icons.people),
            _buildStatTile("Total Businesses", totalBusinesses,
                Colors.green, Icons.business),
            _buildStatTile(
                "Total People", totalPeople, Colors.orange, Icons.person),
            _buildStatTile("Total Prime Users", totalPrime,
                Colors.purple, Icons.star),
          ],
        ),
      ),
    );
  }
}
