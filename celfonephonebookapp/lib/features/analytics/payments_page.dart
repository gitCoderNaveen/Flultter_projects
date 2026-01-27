import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: FutureBuilder(
        future: supabase
            .from('payments')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List;

          if (data.isEmpty) {
            return const Center(child: Text('No payments found'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final p = data[i];
              return ListTile(
                leading: const Icon(Icons.payment),
                title: Text('₹ ${p['amount']}'),
                subtitle: Text(p['status'] ?? 'pending'),
                trailing: Text(
                  p['created_at'].toString().split('T').first,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
