import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatelessWidget {
  SubscriptionPage({super.key});
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> _plans() async {
    return await supabase
        .from('subscription_plans')
        .select()
        .eq('is_active', true)
        .order('price');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Plan')),
      body: FutureBuilder(
        future: _plans(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snap.data as List;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (_, i) {
              final plan = plans[i];
              return ListTile(
                title: Text(
                  '${plan['name'].toUpperCase()} - ₹${plan['price']}',
                ),
                subtitle: Text(
                  '${plan['duration_value']} ${plan['duration_type']}',
                ),
                trailing: ElevatedButton(
                  child: const Text('Subscribe'),
                  onPressed: () => _pay(context, plan),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _pay(BuildContext context, dynamic plan) async {
    final uri = Uri.parse(
      'upi://pay'
      '?pa=yourupi@bank'
      '&pn=Celfon5G'
      '&am=${plan['price']}'
      '&cu=INR'
      '&tn=${plan['name']} Subscription',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Navigate after opening UPI app
      context.push('/payment-confirm', extra: plan);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No UPI app found')));
    }
  }
}
