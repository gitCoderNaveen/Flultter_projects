import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> login() async {
    await supabase.auth.signInWithPassword(
      email: emailCtrl.text,
      password: passCtrl.text,
    );

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password")),
            ElevatedButton(onPressed: login, child: Text("Login")),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
              child: Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}