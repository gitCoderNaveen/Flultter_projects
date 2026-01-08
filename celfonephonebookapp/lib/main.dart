// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure this is imported
import 'firebase_options.dart';
import 'supabase/supabase.dart';
import 'utils/splash_screen.dart';
import 'screens/homepage_shell.dart';
import 'screens/signin.dart'; // ← Ensure your sign-in file is imported
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celfon5G+ Phone Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // The StreamBuilder automatically routes users based on their login status
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Stage4Splash(); // Show splash while checking session
          }

          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            return const HomePageShell(); // Already logged in
          } else {
            return const SigninPage(); // Not logged in, go to Sign-In
          }
        },
      ),
      routes: {
        '/home': (context) => const HomePageShell(),
        '/signin': (context) => const SigninPage(), // ← Updated name here
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}