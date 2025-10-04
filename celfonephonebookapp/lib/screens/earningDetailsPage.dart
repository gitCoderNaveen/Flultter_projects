import 'package:celfonephonebookapp/screens/RevenueDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EarningDetailsPage extends StatefulWidget {
  const EarningDetailsPage({super.key});

  @override
  State<EarningDetailsPage> createState() => _EarningDetailsPageState();
}

class _EarningDetailsPageState extends State<EarningDetailsPage> {
  bool isLoading = true;
  int todayCount = 0;
  int todayEarnings = 0;

  List<Map<String, dynamic>> weeklyReports = [];
  List<Map<String, dynamic>> monthlyReports = [];
  List<Map<String, dynamic>> customReports = [];

  String? userId;
  String? username;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    username = prefs.getString("username");

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
      }
      return;
    }

    await fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    try {
      final now = DateTime.now().toUtc();
      final todayStart = DateTime.utc(now.year, now.month, now.day, 0, 0, 0);
      final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

      // Today’s Data
      final todayData = await Supabase.instance.client
          .from("data_entry_table")
          .select("count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", todayStart.toIso8601String())
          .lte("created_at", todayEnd.toIso8601String())
          .maybeSingle();

      todayCount = todayData?["count"] ?? 0;
      todayEarnings = todayData?["earnings"] ?? 0;

      // Weekly Reports (last 7 days)
      final weekStart = now.subtract(const Duration(days: 7));
      final weeklyData = await Supabase.instance.client
          .from("data_entry_table")
          .select("created_at, count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", weekStart.toIso8601String())
          .order("created_at", ascending: false);
      weeklyReports = List<Map<String, dynamic>>.from(weeklyData);

      // Monthly Reports
      final monthStart = DateTime.utc(now.year, now.month, 1);
      final monthlyData = await Supabase.instance.client
          .from("data_entry_table")
          .select("created_at, count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", monthStart.toIso8601String())
          .order("created_at", ascending: false);
      monthlyReports = List<Map<String, dynamic>>.from(monthlyData);

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching earnings: $e")),
        );
      }
    }
  }

  Future<void> fetchCustomReports(DateTime start, DateTime end) async {
    final data = await Supabase.instance.client
        .from("data_entry_table")
        .select("created_at, count, earnings")
        .eq("user_id", userId!)
        .gte("created_at", start.toIso8601String())
        .lte("created_at", end.toIso8601String())
        .order("created_at", ascending: false);

    setState(() {
      customReports = List<Map<String, dynamic>>.from(data);
    });
  }

  void openReportPage(String title, List<Map<String, dynamic>> reports,
      {bool isCustom = false}) async {
    if (isCustom) {
      // pick custom range
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2023, 1, 1),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        await fetchCustomReports(picked.start, picked.end);
        reports = customReports;
      } else {
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportListPage(title: title, reports: reports),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earning Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchEarnings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Today’s Card
            // Today’s Card
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RevenueDetailsPage(),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Hello, $username 👋",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      const Text("Today’s Stats",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Count: $todayCount",
                          style: const TextStyle(fontSize: 16)),
                      Text("Earnings: ₹$todayEarnings",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ),


            const SizedBox(height: 20),

            // Report Options
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Weekly Reports"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => openReportPage("Weekly Reports", weeklyReports),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("Monthly Reports"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () =>
                  openReportPage("Monthly Reports", monthlyReports),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Custom Reports"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => openReportPage("Custom Reports", [], isCustom: true),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> reports;

  const ReportListPage({super.key, required this.title, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: reports.isEmpty
          ? const Center(child: Text("No data available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          final date =
          DateFormat("dd MMM yyyy").format(DateTime.parse(r["created_at"]));
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text("Date: $date"),
              subtitle: Text("Count: ${r["count"]}, Earnings: ₹${r["earnings"]}"),
            ),
          );
        },
      ),
    );
  }
}
