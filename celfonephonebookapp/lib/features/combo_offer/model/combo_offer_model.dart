import 'package:flutter/material.dart';

class ComboOfferModel {
  final String title;
  final String emoji;
  final Color accentColor;
  final List<String> features;

  ComboOfferModel({
    required this.title,
    required this.emoji,
    required this.accentColor,
    required this.features,
  });
}
