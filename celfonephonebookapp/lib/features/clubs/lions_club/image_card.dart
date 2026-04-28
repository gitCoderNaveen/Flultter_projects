import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String position;
  final double size; // 👈 add this

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.position,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: const Color(0xFF2E86A1),
            borderRadius: BorderRadius.circular(8),
            image: imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          position,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}