import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:celfonephonebookapp/core/enums/user_type.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  Future<void> _resendEmail(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.email == null) return;

    await Supabase.instance.client.auth.resend(
      type: OtpType.signup,
      email: user!.email!,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email sent')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/ic_launcher.png', width: 90),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please check your inbox and verify your email to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _resendEmail(context),
                child: const Text('Resend Email'),
              ),
              TextButton(
                onPressed: () => context.push(
                  '/complete-profile',
                  extra: UserType.business, // or individual
                ),
                child: const Text('Complete Your Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
