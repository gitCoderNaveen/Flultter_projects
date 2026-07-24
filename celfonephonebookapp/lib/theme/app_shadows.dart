import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get hard => [
        BoxShadow(
          color: Colors.black.withOpacity(.12),
          blurRadius: 35,
          offset: const Offset(0, 16),
        ),
      ];
}