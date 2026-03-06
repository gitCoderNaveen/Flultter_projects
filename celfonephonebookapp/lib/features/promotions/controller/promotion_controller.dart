import 'package:celfonephonebookapp/features/promotions/services/promotion_services.dart';
import 'package:flutter/material.dart';

class PromotionController {
  final PromotionServices _services = PromotionServices();

  bool isUserLoggedIn() {
    return _services.isLoggedIn();
  }

  Future<void> logout(BuildContext context) async {
    await _services.logout();
  }

  void protectedNavigation({
    required BuildContext context,
    required Widget destination,
  }) {
    if (_services.isLoggedIn()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login to access this feature"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
