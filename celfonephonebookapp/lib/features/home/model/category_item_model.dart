import 'package:flutter/material.dart';

class CategoryItemModel {
  final String title;
  final String image;
  final String keywords;
  final bool isMore;

  CategoryItemModel({
    required this.title,
    required this.keywords,
    this.image = '',
    this.isMore = false,
  });

  bool get isB2C => keywords.toLowerCase().contains(
        RegExp(r'(hospital|hotel|college|travel|parlour|doctor|shop)'),
      );

  bool get isB2B => keywords.toLowerCase().contains(
        RegExp(r'(chemical|electrical|builder|steel|cnc|hydraulic|electronics)'),
      );

  static IconData iconFor(String keywords) {
    final k = keywords.toLowerCase();
    if (k.contains('hospital')) return Icons.local_hospital;
    if (k.contains('hotel')) return Icons.hotel;
    if (k.contains('college')) return Icons.school;
    if (k.contains('travel')) return Icons.flight_takeoff;
    if (k.contains('doctor')) return Icons.medical_services;
    if (k.contains('shop') || k.contains('parlour')) return Icons.storefront;
    if (k.contains('chemical')) return Icons.science;
    if (k.contains('electrical')) return Icons.electrical_services;
    if (k.contains('steel') || k.contains('builder')) return Icons.construction;
    if (k.contains('cnc') || k.contains('hydraulic')) {
      return Icons.precision_manufacturing;
    }
    if (k.contains('electronics')) return Icons.electric_bolt;
    return Icons.category;
  }

  factory CategoryItemModel.fromMap(Map<String, dynamic> map) {
    return CategoryItemModel(
      title: map['group_title'] ?? map['title'] ?? '',
      image: map['image'] ?? map['image_url'] ?? '',
      keywords: map['image_keywords'] ?? map['keywords'] ?? '',
    );
  }
}
