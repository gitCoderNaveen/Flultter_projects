import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final Set<String> _expandedMonths = {};

  Future<List<dynamic>> _fetchAllPayments() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return [];
    try {
      final sProfile = await SupabaseService.client
          .from('s_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final res = await SupabaseService.client
          .from('data_entry_name')
          .select()
          .eq('user_id', sProfile['id'])
          .order('created_at', ascending: false);

      return res as List;
    } catch (e) {
      return [];
    }
  }

  List<DateTime> _getYearMonths() {
    final now = DateTime.now();
    return List.generate(now.month, (i) => DateTime(now.year, now.month - i));
  }

  Map<String, List<dynamic>> _groupByMonth(List<dynamic> data) {
    final Map<String, List<dynamic>> grouped = {};
    for (final item in data) {
      final dt = DateTime.parse(item['created_at']).toLocal();
      final key = DateFormat('yyyy-MM').format(dt);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    for (final list in grouped.values) {
      list.sort((a, b) {
        final aP = (a['status'] ?? '').toString().toLowerCase() == 'paid';
        final bP = (b['status'] ?? '').toString().toLowerCase() == 'paid';
        if (aP == bP) return 0;
        return aP ? 1 : -1;
      });
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          "Payment History",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchAllPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF1F8EB6),
              ),
            );
          }

          final all = snapshot.data ?? [];
          final grouped = _groupByMonth(all);
          final months = _getYearMonths();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              ...months.map((monthDt) {
                final key = DateFormat('yyyy-MM').format(monthDt);
                final label = DateFormat('MMMM yyyy').format(monthDt);
                final items = grouped[key] ?? [];
                final mPaid = items
                    .where((e) => (e['status'] ?? '') == 'paid')
                    .length;
                final mUnpaid = items.length - mPaid;
                final mAmount = items.length * 2;
                final isEmpty = items.isEmpty;
                final isOpen = _expandedMonths.contains(key);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isOpen
                          ? const Color(0xFF1F8EB6).withOpacity(0.4)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ── MONTH HEADER ──
                      GestureDetector(
                        onTap: isEmpty
                            ? null
                            : () => setState(() {
                                isOpen
                                    ? _expandedMonths.remove(key)
                                    : _expandedMonths.add(key);
                              }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isOpen
                                ? const Color(0xFF1F8EB6).withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              // Calendar icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isEmpty
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(
                                          0xFF1F8EB6,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                  color: isEmpty
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF1F8EB6),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Month name + subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isEmpty
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isEmpty
                                          ? "No entries"
                                          : "${items.length} entries  •  ₹$mAmount.00",
                                      style: TextStyle(
                                        color: isEmpty
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF64748B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Pills + arrow
                              if (!isEmpty) ...[
                                _buildPill(
                                  "✓$mPaid",
                                  const Color(0xFFD1FAE5),
                                  const Color(0xFF059669),
                                ),
                                const SizedBox(width: 5),
                                _buildPill(
                                  "⏳$mUnpaid",
                                  const Color(0xFFFEF3C7),
                                  const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: isOpen ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF1F8EB6),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // ── EXPANDED ENTRIES ──
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: isOpen
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            Divider(
                              height: 1,
                              color: const Color(0xFF1F8EB6).withOpacity(0.15),
                              indent: 16,
                              endIndent: 16,
                            ),
                            const SizedBox(height: 8),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  8,
                                ),
                                child: _buildTransactionItem(item),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }

  // ── TRANSACTION ITEM ──────────────────────────────────────────────────────
  Widget _buildTransactionItem(dynamic item) {
    final DateTime dt = DateTime.parse(item['created_at']).toLocal();
    final bool isPaid =
        (item['status'] ?? 'unpaid').toString().toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['entryname'] ?? 'Data Entry Fee',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy • hh:mm a').format(dt),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+₹2.00",
                style: TextStyle(
                  color: isPaid
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD97706),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isPaid ? "PAID" : "UNPAID",
                  style: TextStyle(
                    color: isPaid
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
