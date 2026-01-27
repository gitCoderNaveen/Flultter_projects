import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentConfirmPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  PaymentConfirmPage({super.key, required this.plan});

  @override
  State<PaymentConfirmPage> createState() => _PaymentConfirmPageState();
}

class _PaymentConfirmPageState extends State<PaymentConfirmPage> {
  final _txnController = TextEditingController();
  bool _loading = false;

  Future<void> _confirmPayment() async {
    if (_txnController.text.isEmpty) return;

    setState(() => _loading = true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser!;

    try {
      // 1. Store payment record
      final payment = await supabase
          .from('payments')
          .insert({
            'user_id': user.id,
            'plan_id': widget.plan['id'],
            'amount': widget.plan['price'],
            'upi_ref_id': _txnController.text.trim(),
            'status': 'success',
          })
          .select()
          .single();

      // 2. Activate subscription
      final start = DateTime.now();
      final end = _calculateEndDate(widget.plan, start);

      await supabase.from('user_subscriptions').insert({
        'user_id': user.id,
        'plan_id': widget.plan['id'],
        'start_date': start.toIso8601String(),
        'end_date': end.toIso8601String(),
        'status': 'active',
      });

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  DateTime _calculateEndDate(Map<String, dynamic> plan, DateTime start) {
    final int duration = (plan['duration_value'] as num).toInt();

    switch (plan['duration_type']) {
      case 'day':
        return start.add(Duration(days: duration));

      case 'month':
        return DateTime(start.year, start.month + duration, start.day);

      case 'year':
        return DateTime(start.year + duration, start.month, start.day);

      default:
        return start;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan: ${widget.plan['name'].toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Amount: ₹${widget.plan['price']}'),
            const SizedBox(height: 24),

            TextField(
              controller: _txnController,
              decoration: const InputDecoration(
                labelText: 'UPI Transaction ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmPayment,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm & Activate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
