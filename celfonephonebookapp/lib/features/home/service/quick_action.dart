import 'package:flutter/material.dart';

class QuickAction {

  final String title;

  final IconData icon;

  final Color color;

  final VoidCallback onTap;

  QuickAction({

    required this.title,

    required this.icon,

    required this.color,

    required this.onTap,
  });

}