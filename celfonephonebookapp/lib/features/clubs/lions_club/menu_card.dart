import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF2E86A1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}