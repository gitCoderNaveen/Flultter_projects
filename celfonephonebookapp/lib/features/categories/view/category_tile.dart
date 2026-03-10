import 'package:flutter/material.dart';
import '../model/category_item.dart';

class CategoryTile extends StatelessWidget {
  final CategoryItem item;

  const CategoryTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.pink.shade50,
          backgroundImage:
              item.image.isNotEmpty && item.image.startsWith('http')
              ? NetworkImage(item.image)
              : null,
          child: item.image.isEmpty
              ? Icon(
                  CategoryItem.iconFor(item.keywords),
                  color: Colors.pinkAccent,
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
