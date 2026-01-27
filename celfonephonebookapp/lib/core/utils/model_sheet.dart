import 'package:flutter/material.dart';
import '../../features/profile/ui/model_page.dart';

Future<void> openProfileModal(
  BuildContext context,
  Map<String, dynamic> profile,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.7,
        maxChildSize: 0.98,
        expand: false,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: Colors.white,
              child: ModelPage(profile: profile),
            ),
          );
        },
      );
    },
  );
}
