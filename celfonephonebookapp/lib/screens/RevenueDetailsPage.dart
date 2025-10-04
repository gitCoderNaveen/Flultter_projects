import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueDetailsPage extends StatefulWidget {
  const RevenueDetailsPage({super.key});

  @override
  State<RevenueDetailsPage> createState() => _RevenueDetailsPageState();
}

class _RevenueDetailsPageState extends State<RevenueDetailsPage> {
  bool isLoading = true;
  String? userId;
  List<Map<String, dynamic>> revenueData = [];
  int totalEntries = 0;
  int totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
      }
      return;
    }
    await fetchRevenueDetails();
  }

  Future<void> fetchRevenueDetails() async {
    try {
      final now = DateTime.now().toUtc();
      final todayStart = DateTime.utc(now.year, now.month, now.day, 0, 0, 0);
      final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

      // 1. Fetch entry_name + scheme from data_entry_name
      final details = await Supabase.instance.client
          .from("data_entry_name")
          .select("entry_name, scheme, created_at")
          .eq("user_id", userId!)
          .gte("created_at", todayStart.toIso8601String())
          .lte("created_at", todayEnd.toIso8601String())
          .order("created_at", ascending: false);

      revenueData = List<Map<String, dynamic>>.from(details);

      // 2. Fetch total entries + earnings from data_entry_table
      final todayData = await Supabase.instance.client
          .from("data_entry_table")
          .select("count, earnings")
          .eq("user_id", userId!)
          .gte("created_at", todayStart.toIso8601String())
          .lte("created_at", todayEnd.toIso8601String())
          .maybeSingle();

      totalEntries = todayData?["count"] ?? 0;
      totalEarnings = todayData?["earnings"] ?? 0;

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching revenue: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Revenue Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : revenueData.isEmpty
          ? const Center(child: Text("No revenue data available"))
          : RefreshIndicator(
        onRefresh: fetchRevenueDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Earning Details:",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Entry-wise list
            ...revenueData.map((r) {
              final date = DateFormat("dd MMM yyyy, hh:mm a")
                  .format(DateTime.parse(r["created_at"]));
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.work),
                  title: Text("Entered Name: ${r["entry_name"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Earning Value: ${r["scheme"]}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green)),
                      const SizedBox(height: 4),
                      Text("Date: $date",
                          style:
                          const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Totals Section
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Data Entries: $totalEntries",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    const SizedBox(height: 8),
                    Text("Total Earnings: ₹$totalEarnings",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
