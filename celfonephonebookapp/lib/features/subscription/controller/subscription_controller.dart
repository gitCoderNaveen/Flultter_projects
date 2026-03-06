import 'package:celfonephonebookapp/features/subscription/model/subscription_plan.dart';
import 'package:flutter/material.dart';

class SubscriptionController {
  static const Color goldColor = Color(0xFFC5A000);
  static const Color magentaColor = Color(0xFFFF00FF);
  static const Color lightGreenColor = Color(0xFF2E7D32);

  List<String> allUniqueFeatures = [
    "Address",
    "Communication",
    "Enquiry",
    "Position",
    "Highlight",
    "Description",
    "Location Map",
    "Web Site Link",
    "Verified Leads",
    "Product Photos",
    "Product Pricing",
    "WhatsApp Integration",
  ];

  List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      title: "FREE Listing",
      pmLabel: "",
      paLabel: "",
      color: const Color(0xFF424242),
      rowColor: const Color.fromARGB(255, 255, 253, 253),
      hasDiscount: false,
      features: ["Address", "Communication", "Enquiry"],
      positionText: "--",
    ),
    SubscriptionPlan(
      title: "BUSINESS Listing",
      pmLabel: "Rs 200 PM",
      paLabel: "Rs 2,000 PA",
      color: magentaColor,
      rowColor: const Color(0xFFE8F5E9),
      hasDiscount: true,
      features: [
        "Address",
        "Communication",
        "Enquiry",
        "Position",
        "Highlight",
        "Description",
        "Location Map",
        "Web Site Link",
      ],
      positionText: "TOP 10",
    ),
    SubscriptionPlan(
      title: "PRIORITY Business",
      pmLabel: "Rs 500 PM",
      paLabel: "Rs 5,000 PA",
      color: Colors.blue,
      rowColor: const Color(0xFFFDF0F5),
      hasDiscount: true,
      features: [
        "Address",
        "Communication",
        "Enquiry",
        "Position",
        "Highlight",
        "Description",
        "Location Map",
        "Web Site Link",
        "Verified Leads",
      ],
      positionText: "TOP 5",
    ),
    SubscriptionPlan(
      title: "PREMIUM Listing",
      pmLabel: "Rs 750 PM",
      paLabel: "Rs 7,500 PA",
      color: goldColor,
      rowColor: const Color(0xFFFFFDE7),
      hasDiscount: true,
      features: [
        "Address",
        "Communication",
        "Enquiry",
        "Position",
        "Highlight",
        "Description",
        "Location Map",
        "Web Site Link",
        "Verified Leads",
        "Product Photos",
        "Product Pricing",
        "WhatsApp Integration",
      ],
      positionText: "TOP 2",
    ),
  ];

  Color getRowColor(String feature) {
    for (var plan in plans) {
      if (plan.features.contains(feature)) {
        return plan.rowColor;
      }
    }
    return Colors.white;
  }
}
