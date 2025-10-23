import 'package:flutter/material.dart';

class AuthField extends StatelessWidget{
  final String hintText;
  const AuthField ({super.key, required this.hintText});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText:hintText,
      ),
    );

  }
}