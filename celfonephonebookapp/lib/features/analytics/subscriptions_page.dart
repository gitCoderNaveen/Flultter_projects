import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Subscription')),
      body: FutureBuilder(
        future: supabase
            .from('user_subscriptions')
            .select('*, subscription_plans(*)')
            .eq('user_id', user!.id)
            .order('created_at', ascending: false)
            .maybeSingle(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sub = snapshot.data;
          if (sub == null) {
            return const Center(child: Text('No active subscription'));
          }

          final plan = sub['subscription_plans'];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Price: ₹${plan['price']}'),
                    Text(
                      'Duration: ${plan['duration_value']} ${plan['duration_type']}',
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(sub['status']),
                      backgroundColor: sub['status'] == 'active'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
