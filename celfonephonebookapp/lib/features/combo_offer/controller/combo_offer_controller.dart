import 'package:flutter/material.dart';
import '../model/combo_offer_model.dart';

class ComboOfferController {
  List<ComboOfferModel> offers = [
    ComboOfferModel(
      title: "DIAMOND - Rs",
      emoji: "💎",
      accentColor: const Color(0xFF00838F),
      features: [
        "Banner Ad in Home page (App)",
        "Full page Ad in directory book (Print)",
        "Full page Ad in digital edition",
      ],
    ),

    ComboOfferModel(
      title: "GOLD - Rs",
      emoji: "👑",
      accentColor: const Color(0xFFB8860B),
      features: [
        "Popular Firms in Home page (App)",
        "1/4 page Ad in directory book (Print)",
        "1/4 page Ad in digital edition",
      ],
    ),

    ComboOfferModel(
      title: "SILVER - Rs",
      emoji: "🔘",
      accentColor: const Color(0xFF546E7A),
      features: ["Premium listing (App)", "Box Ad (Print)", "Box Ad (Digital)"],
    ),
  ];
}
