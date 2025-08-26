import 'package:flutter/material.dart';

class OffersPage extends  StatelessWidget{
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> promotions = [
      {
        "title": "50% OFF on Electronics",
        "description": "Grab the best deals on mobiles, laptops & gadgets.",
        "image": "assets/images/add1.png"
      },
      {
        "title": "Food Fiesta",
        "description": "Get flat 30% discount on your favorite restaurants.",
        "image": "assets/images/add2.png"
      },
      {
        "title": "Fashion Week Sale",
        "description": "Exclusive discounts on top fashion brands.",
        "image": "assets/images/add3.png"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Offers"),
      ),
      body: ListView.builder(
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    promo["image"]!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo["title"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        promo["description"]!,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
