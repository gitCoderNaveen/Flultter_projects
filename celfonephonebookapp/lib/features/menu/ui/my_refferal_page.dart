import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyReferralPage extends StatefulWidget {
  const MyReferralPage({super.key});

  @override
  State<MyReferralPage> createState() => _MyReferralPageState();
}

class _MyReferralPageState extends State<MyReferralPage> {
  final _supabase = Supabase.instance.client;

  Map<String, List<Map<String, dynamic>>> _groupedData = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await _supabase
          .from('s_profiles')
          .select('promo_code, full_name, phone, city, created_at')
          .not('promo_code', 'is', null)
          .order('created_at', ascending: false);

      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final row in List<Map<String, dynamic>>.from(rows)) {
        // ✅ toUpperCase() — "shiva" and "SHIVA" both → "SHIVA"
        final code = (row['promo_code'] as String?)?.trim().toUpperCase() ?? '';
        if (code.isEmpty) continue;
        grouped.putIfAbsent(code, () => []).add(row);
      }

      setState(() {
        _groupedData = grouped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Referrals'),
        backgroundColor: const Color(0xFF1F8EB6),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _groupedData.isEmpty
          ? const Center(
              child: Text(
                'No referral data found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem('${_groupedData.length}', 'Promo Codes'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.teal.shade200,
                        ),
                        _summaryItem(
                          '${_groupedData.values.fold(0, (sum, list) => sum + list.length)}',
                          'Total Members',
                        ),
                      ],
                    ),
                  ),
                  ..._groupedData.entries.map((entry) {
                    return _PromoAccordion(
                      promoCode: entry.key,
                      users: entry.value,
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
        ),
      ],
    );
  }
}

class _PromoAccordion extends StatefulWidget {
  final String promoCode;
  final List<Map<String, dynamic>> users;

  const _PromoAccordion({required this.promoCode, required this.users});

  @override
  State<_PromoAccordion> createState() => _PromoAccordionState();
}

class _PromoAccordionState extends State<_PromoAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1.5,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.promoCode, // already UPPERCASED
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.users.length} ${widget.users.length == 1 ? 'member' : 'members'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ...widget.users.map((u) {
              final name =
                  (u['full_name'] as String?)?.trim().isNotEmpty == true
                  ? u['full_name'] as String
                  : 'Unknown';
              final phone = (u['phone'] as String?) ?? '-';
              final city = (u['city'] as String?) ?? '';
              final createdAt = u['created_at'] != null
                  ? DateTime.tryParse(u['created_at'] as String)
                  : null;
              final joinDate = createdAt != null
                  ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                  : '';

              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.teal.shade50,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  [phone, if (city.isNotEmpty) city].join(' • '),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: joinDate.isNotEmpty
                    ? Text(
                        joinDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
