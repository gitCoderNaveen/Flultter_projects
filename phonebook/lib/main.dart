import 'package:flutter/material.dart';
import 'package:phonebook/core/theme/theme.dart';
import 'package:phonebook/features/auth/presentation/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Book',
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
      home: const SignUpPage(),
    );
  }

}
