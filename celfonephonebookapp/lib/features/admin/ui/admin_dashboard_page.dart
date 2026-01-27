import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final supabase = Supabase.instance.client;

  int totalViews = 0;
  int totalLeads = 0;
  int totalUsers = 0;
  double conversionRate = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => loading = true);

    final viewsRes = await supabase
        .from('user_session')
        .select('id')
        .eq('action', 'view');

    final leadsRes = await supabase.from('search_logs').select('id');

    final usersRes = await supabase.from('profiles').select('id');

    final int views = viewsRes.length;
    final int leads = leadsRes.length;
    final int users = usersRes.length;

    setState(() {
      totalViews = views;
      totalLeads = leads;
      totalUsers = users;
      conversionRate = views == 0 ? 0 : (leads / views * 100).clamp(0, 100);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatCard(
                    title: 'Total Views',
                    value: totalViews.toString(),
                    icon: Icons.visibility,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Total Leads',
                    value: totalLeads.toString(),
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Conversion Rate',
                    value: '${conversionRate.toStringAsFixed(1)}%',
                    icon: Icons.analytics,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),

                  /// Future-ready placeholders
                  const Text(
                    'Charts (Coming Next)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _PlaceholderChart(),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderChart extends StatelessWidget {
  const _PlaceholderChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Line / Bar charts will be added here',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
