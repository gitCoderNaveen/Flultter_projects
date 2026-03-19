import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_detail.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allProfiles = [];
  List<dynamic> _filteredProfiles = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _countAnimation;
  int _targetCount = 0;
  int _displayCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fetchTurboData();
    //   _searchController.addListener(() {
    //   setState(() {});
    // });
  }

  // SAFE INITIALS HELPER
  String _getSafeInitial(dynamic name) {
    if (name == null) return "?";
    String nameStr = name.toString().trim();
    if (nameStr.isEmpty) return "?";
    return nameStr[0].toUpperCase();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTurboData() async {
    setState(() => _isLoading = true);
    try {
      final countResponse = await supabase
          .from('profiles')
          .select('*')
          .count(CountOption.exact);
      _targetCount = countResponse.count;

      _countAnimation =
          Tween<double>(begin: 0, end: _targetCount.toDouble()).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuart,
            ),
          )..addListener(() {
            setState(() {
              _displayCount = _countAnimation.value.toInt();
            });
          });
      _animationController.forward();

      List<dynamic> allFetched = [];
      bool hasMore = true;
      int offset = 0;
      const int pageSize = 1000;

      while (hasMore) {
        final data = await supabase
            .from('profiles')
            .select()
            .range(offset, offset + pageSize - 1)
            .order('created_at', ascending: false);

        allFetched.addAll(data);

        if (allFetched.length == 1000 ||
            allFetched.length % 5000 == 0 ||
            data.length < pageSize) {
          if (mounted) {
            setState(() {
              _allProfiles = allFetched;
              if (_searchController.text.isEmpty)
                _filteredProfiles = allFetched;
            });
          }
        }
        if (data.length < pageSize)
          hasMore = false;
        else
          offset += pageSize;
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterProfiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = _allProfiles;
      } else {
        final q = query.toLowerCase();
        _filteredProfiles = _allProfiles.where((p) {
          final name = (p['person_name'] ?? '').toString().toLowerCase();
          final business = (p['business_name'] ?? '').toString().toLowerCase();
          final mobile = (p['mobile_number'] ?? '').toString().toLowerCase();
          return name.contains(q) || business.contains(q) || mobile.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "System Admin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: _animationController.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.blue[50],
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      "${(_animationController.value * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "DATABASE RECORDS",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "$_displayCount",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Syncing: ${((_allProfiles.length / (_targetCount == 0 ? 1 : _targetCount)) * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  onChanged: _filterProfiles,
                  decoration: InputDecoration(
                    hintText: "Search records...",
                    prefixIcon: const Icon(Icons.search_rounded),

                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterProfiles("");
                            },
                          )
                        : null,

                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),

          // Data List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredProfiles.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final profile = _filteredProfiles[index];

                // Helper variables for layout
                final String businessName =
                    profile['business_name']?.toString() ??
                    'Individual / No Business';
                final String phoneNumber =
                    profile['mobile_number']?.toString() ?? 'No Phone';
                final String personName =
                    profile['person_name']?.toString() ?? 'Unknown';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: Text(
                      _getSafeInitial(personName),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_android_rounded,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              phoneNumber,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          personName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileDetailScreen(profile: profile),
                      ),
                    );
                    _filterProfiles(_searchController.text);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
