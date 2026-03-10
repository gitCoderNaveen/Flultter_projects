import 'package:flutter/material.dart';

class MoreCategoryTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MoreCategoryTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.pink.shade100,
            child: const Text(
              "More",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}