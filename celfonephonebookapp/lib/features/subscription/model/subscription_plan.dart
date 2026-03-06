import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String title;
  final String pmLabel;
  final String paLabel;
  final Color color;
  final Color rowColor;
  final bool hasDiscount;
  final List<String> features;
  final String positionText;

  SubscriptionPlan({
    required this.title,
    required this.pmLabel,
    required this.paLabel,
    required this.color,
    required this.rowColor,
    required this.hasDiscount,
    required this.features,
    required this.positionText,
  });
}
