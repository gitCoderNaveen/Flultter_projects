import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> signup() async {
    await supabase.auth.signUp(
      email: emailCtrl.text,
      password: passCtrl.text,
    );

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password")),
            ElevatedButton(onPressed: signup, child: Text("Signup")),
          ],
        ),
      ),
    );
  }
}