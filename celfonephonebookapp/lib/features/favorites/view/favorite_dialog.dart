import 'package:flutter/material.dart';

class FavoriteDialog extends StatelessWidget {
  final Function(String) onSelected;

  const FavoriteDialog({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final groups = ["My Buyers", "My Sellers", "Family & Friends", "My List"];

    return AlertDialog(
      title: const Text("Choose Group"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: groups.map((group) {
          return ListTile(
            title: Text(group),
            onTap: () {
              Navigator.pop(context);
              onSelected(group);
            },
          );
        }).toList(),
      ),
    );
  }
}
