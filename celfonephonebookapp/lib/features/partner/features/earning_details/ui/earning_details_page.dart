import 'package:celfonephonebookapp/Supabase/Supabase.dart';
import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/partner/features/earning_details/model/earning_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EarningDetailsPage extends StatefulWidget {
  const EarningDetailsPage({super.key});

  @override
  State<EarningDetailsPage> createState() => _EarningDetailsPageState();
}

class _EarningDetailsPageState extends State<EarningDetailsPage> {
  // ================= STATE VARIABLES =================

  List<EarningModel> activities = [];
  bool isLoading = false;

  String selectedPeriod = "Weekly";
  DateTime _viewDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  DateTimeRange? _customRange;
  late Future<Map<String, dynamic>> _lifetimeStatsFuture;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _lifetimeStatsFuture = _fetchLifetimeStats();
  }

  Future<Map<String, dynamic>> _fetchLifetimeStats() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return {'count': 0, 'earn': 0};
    try {
      final sProfile = await SupabaseService.client
          .from('s_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();
      final stats = await SupabaseService.client
          .from('data_entry_table')
          .select('count, earnings')
          .eq('user_id', sProfile['id']);
      int totalCount = 0;
      int totalEarn = 0;
      for (var row in stats) {
        totalCount += (row['count'] as int? ?? 0);
        totalEarn += (row['earnings'] as int? ?? 0);
      }
      return {'count': totalCount, 'earn': totalEarn};
    } catch (e) {
      return {'count': 0, 'earn': 0};
    }
  }

  Future<List<dynamic>> _fetchFilteredActivities() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return [];
    try {
      final sProfile = await SupabaseService.client
          .from('s_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();
      DateTime start;
      DateTime end;

      if (selectedPeriod == 'Weekly') {
        start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          0,
          0,
          0,
        );
        end = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          23,
          59,
          59,
        );
      } else if (selectedPeriod == 'Monthly') {
        start = DateTime(_selectedDate.year, _selectedDate.month, 1);
        end = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          0,
          23,
          59,
          59,
        );
      } else {
        if (_customRange == null) return [];
        start = _customRange!.start;
        end = _customRange!.end.add(const Duration(hours: 23, minutes: 59));
      }

      final res = await SupabaseService.client
          .from('data_entry_name')
          .select()
          .eq('user_id', sProfile['id'])
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at', ascending: false);
      return res as List;
    } catch (e) {
      return [];
    }
  }

  Future<void> _pickCustomRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6366F1),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (result != null) {
      setState(() {
        _customRange = result;
        selectedPeriod = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryIndigo = Color(0xFF1F8EB6);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Modern Light Slate background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Earnings Details",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // LIFETIME & PERIOD STATS CARD
          FutureBuilder<Map<String, dynamic>>(
            future: _lifetimeStatsFuture,
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {'count': 0, 'earn': 0};
              return FutureBuilder<List<dynamic>>(
                future: _fetchFilteredActivities(),
                builder: (context, activitySnapshot) {
                  final activities = activitySnapshot.data ?? [];
                  int periodCount = activities.length;
                  int periodEarn = periodCount * 2;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildCombinedHeader(
                      snapshot.connectionState == ConnectionState.waiting,
                      stats['count'],
                      stats['earn'],
                      periodCount,
                      periodEarn,
                    ),
                  );
                },
              );
            },
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 15),
                  if (selectedPeriod != 'Custom') _buildTimelineHeader(),
                  const SizedBox(height: 10),
                  if (selectedPeriod == 'Weekly')
                    _buildWeeklyTimeline()
                  else if (selectedPeriod == 'Monthly')
                    _buildMonthlyTimeline()
                  else
                    _buildCustomRangeHeader(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _fetchFilteredActivities(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        final activities = snapshot.data ?? [];
                        return activities.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: activities.length,
                                itemBuilder: (context, index) =>
                                    _buildActivityTile(activities[index]),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedHeader(
    bool loading,
    int totalCount,
    int totalEarn,
    int pCount,
    int pEarn,
  ) {
    String pLabel = "Today";
    if (selectedPeriod == 'Weekly')
      pLabel = "Selected Day";
    else if (selectedPeriod == 'Monthly')
      pLabel = "Monthly";
    else if (selectedPeriod == 'Custom')
      pLabel = "Range";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F8EB6), Color(0xFF1F8EB6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F8EB6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "LIFETIME TOTAL EARNINGS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loading ? "₹..." : "₹$totalEarn",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "$totalCount Lifetime Entries",
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubStat("$pLabel Entries", "$pCount"),
                Container(width: 1, height: 25, color: Colors.white24),
                _buildSubStat("$pLabel Earnings", "₹$pEarn"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String val) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );

  Widget _buildTimelineHeader() {
    String headerText = "";
    if (selectedPeriod == 'Weekly') {
      DateTime monday = _viewDate.subtract(
        Duration(days: _viewDate.weekday - 1),
      );
      DateTime sunday = monday.add(const Duration(days: 6));
      headerText =
          "${DateFormat('dd MMM').format(monday)} - ${DateFormat('dd MMM').format(sunday)}";
    } else if (selectedPeriod == 'Monthly') {
      headerText = DateFormat('yyyy').format(_viewDate);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleNavButton(
          Icons.chevron_left,
          () => setState(() {
            if (selectedPeriod == 'Weekly')
              _viewDate = _viewDate.subtract(const Duration(days: 7));
            else
              _viewDate = DateTime(_viewDate.year - 1, _viewDate.month);
          }),
        ),
        Text(
          headerText,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
            fontSize: 15,
          ),
        ),
        _circleNavButton(
          Icons.chevron_right,
          _viewDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))
              ? null
              : () => setState(() {
                  if (selectedPeriod == 'Weekly')
                    _viewDate = _viewDate.add(const Duration(days: 7));
                  else
                    _viewDate = DateTime(_viewDate.year + 1, _viewDate.month);
                }),
        ),
      ],
    );
  }

  Widget _circleNavButton(IconData icon, VoidCallback? onTap) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? Colors.grey.shade300 : const Color(0xFF6366F1),
        ),
      ),
    ),
  );

  Widget _buildPeriodSelector() => Container(
    height: 50,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: ['Weekly', 'Monthly', 'Custom'].map((p) {
        bool isSel = selectedPeriod == p;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              selectedPeriod = p;
              _viewDate = DateTime.now();
              if (p == 'Custom' && _customRange == null) _pickCustomRange();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1F8EB6) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                p,
                style: TextStyle(
                  color: isSel ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildCustomRangeHeader() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF1F8EB6).withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickCustomRange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF1F8EB6),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _customRange == null
                      ? "Select Date Range"
                      : "${DateFormat('dd MMM').format(_customRange!.start)} - ${DateFormat('dd MMM').format(_customRange!.end)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F8EB6),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_customRange != null)
          IconButton(
            onPressed: () => setState(() => _customRange = null),
            icon: const Icon(
              Icons.cancel_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
          ),
      ],
    ),
  );

  Widget _buildWeeklyTimeline() {
    DateTime monday = _viewDate.subtract(Duration(days: _viewDate.weekday - 1));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          DateTime day = monday.add(Duration(days: index));
          bool isFuture = day.isAfter(DateTime.now());
          bool isSel =
              _selectedDate.day == day.day &&
              _selectedDate.month == day.month &&
              _selectedDate.year == day.year;
          return GestureDetector(
            onTap: isFuture ? null : () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1F8EB6) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Opacity(
                opacity: isFuture ? 0.3 : 1.0,
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(day),
                      style: TextStyle(
                        color: isSel ? Colors.white70 : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: isSel ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyTimeline() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(12, (index) {
          DateTime monthDate = DateTime(_viewDate.year, index + 1);
          bool isFutureMonth = monthDate.isAfter(DateTime.now());
          bool isSel =
              _selectedDate.month == monthDate.month &&
              _selectedDate.year == monthDate.year;
          return GestureDetector(
            onTap: isFutureMonth
                ? null
                : () => setState(() => _selectedDate = monthDate),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1F8EB6) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Opacity(
                opacity: isFutureMonth ? 0.3 : 1.0,
                child: Text(
                  DateFormat('MMM').format(monthDate),
                  style: TextStyle(
                    color: isSel ? Colors.white : const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityTile(dynamic item) {
    DateTime dt = DateTime.parse(item['created_at']).toLocal();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Color(0xFF1F8EB6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['entryname'] ?? 'Entry',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('hh:mm a').format(dt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "+₹2",
            style: TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No entries found",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Text(
            "Try picking a different date",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
