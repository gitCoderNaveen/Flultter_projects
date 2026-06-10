import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  int _viewsCount = 0;
  int _leadsCount = 0;
  List<Map<String, dynamic>> _recentLeads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final shopId = user.id;

      // 1. Profiles data fetch
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', shopId)
          .maybeSingle();

      // 2. Views data fetch
      final views = await _supabase
          .from('views')
          .select()
          .eq('shop_id', shopId);

      // Verified status check
      final isVerified = profile != null && profile['verified'] == true;

      List<dynamic> leadsData = [];

      // 3. Verified true-ah iruntha mattum leads fetch aagum bro
      if (isVerified) {
        leadsData = await _supabase
            .from('leads')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
      }

      setState(() {
        _profile = profile;
        _viewsCount = (views as List<dynamic>).length;
        _leadsCount = leadsData.length;
        _recentLeads = leadsData
            .take(5)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- FIRST PRIORITY BUSINESS NAME LOGIC ---
    final businessName = _profile?['business_name'] as String?;
    final personName = _profile?['person_name'] as String?;

    // Business name irundha athu, illana person name, rathum illana '-' kaatum bro
    final displayName = (businessName != null && businessName.trim().isNotEmpty)
        ? businessName
        : (personName != null && personName.trim().isNotEmpty)
        ? personName
        : '-';

    final profileImage = _profile?['profile_image'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FE),
      body: Stack(
        children: [
          // --- BACKGROUND SHAPES ---
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3AB1FF).withOpacity(0.4),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8CE3FF).withOpacity(0.35),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // --- MAIN UI ---
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // --- HEADER ---
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Color(0xFF1E293B),
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // --- PROFILE SECTION ---
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.8),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white24,
                                    backgroundImage:
                                        (profileImage != null &&
                                            profileImage.isNotEmpty)
                                        ? NetworkImage(profileImage)
                                        : null,
                                    child:
                                        (profileImage == null ||
                                            profileImage.isEmpty)
                                        ? Text(
                                            displayName != '-'
                                                ? displayName[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (_profile?['email'] as String?) ?? '-',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(
                                          0xFF1E293B,
                                        ).withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      (_profile?['mobile_number'] as String?) ??
                                          '-',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(
                                          0xFF1E293B,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // --- EDIT BUTTON ---
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.push('/profile'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.8),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.edit_rounded,
                                        color: Color(0xFF1E293B),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(
                                            0xFF1E293B,
                                          ).withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // --- STAT CARDS ---
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  value: _viewsCount > 999
                                      ? '${(_viewsCount / 1000).toStringAsFixed(1)}k'
                                      : '$_viewsCount',
                                  title: 'Views',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  value: '$_leadsCount',
                                  title: 'Leads',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // --- RECENT LEADS TITLE ---
                          const Text(
                            'Recent Leads',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // --- LEADS LIST ---
                          _recentLeads.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'No leads yet',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF1E293B,
                                        ).withOpacity(0.4),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentLeads.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final lead = _recentLeads[index];
                                    final name =
                                        (lead['viewer_name'] as String?) ?? '-';
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.45,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: const Color(
                                                  0xFF3AB1FF,
                                                ).withOpacity(0.2),
                                                child: Text(
                                                  name.isNotEmpty
                                                      ? name[0].toUpperCase()
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: Color(0xFF1E293B),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF1E293B,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      lead['created_at'] != null
                                                          ? _formatDate(
                                                              lead['created_at']
                                                                  as String,
                                                            )
                                                          : '-',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                          0xFF1E293B,
                                                        ).withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '-';
    }
  }
}

// --- STAT CARD ---
class StatCard extends StatelessWidget {
  final String value;
  final String title;

  const StatCard({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
