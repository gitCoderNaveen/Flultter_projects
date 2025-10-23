import 'package:flutter/material.dart';
import 'package:phonebook/features/auth/presentation/Widgets/auth_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

@override
  State <SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Celfon5G+', style: TextStyle(fontSize: 45,
          fontWeight: FontWeight.bold),
          ),
          AuthField(hintText: "Mobile Numer"),
        ],
      )
    );
  }
} 