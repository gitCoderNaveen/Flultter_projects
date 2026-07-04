import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8fd),
      body: SafeArea(
        child: Column(
          children: [
            //================ HEADER =================
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0E4DB7), Color(0xff1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.menu, color: Colors.white),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: "Cel",
                                  style: TextStyle(color: Colors.red),
                                ),
                                TextSpan(
                                  text: "fon",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                TextSpan(
                                  text: " Book",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        Stack(
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              size: 28,
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    "3",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Connects For Growth",
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back!",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Let's grow your business today",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bar_chart, size: 18),

                              SizedBox(width: 5),

                              Text("Stats"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //================ BODY =================
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xfff5f8fd),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),

                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _promotionCard(
                      context,
                      title: "Nearby Promotion",
                      subtitle: "Reach customers in your immediate radius",
                      icon: Icons.location_on,
                      color1: Colors.blue.shade50,
                      color2: Colors.white,
                      iconColor: Colors.blue,
                      arrowColor: Colors.blue,
                      badge: "12,450+ businesses using",
                      onTap: () {
                        context.push("/nearby-promotion");
                      },
                    ),

                    const SizedBox(height: 18),

                    _promotionCard(
                      context,
                      title: "Categorywise Promotion",
                      subtitle:
                          "Target specific industries and business categories",
                      icon: Icons.grid_view_rounded,
                      color1: Colors.green.shade50,
                      color2: Colors.white,
                      iconColor: Colors.green,
                      arrowColor: Colors.green,
                      badge: "8,230+ businesses using",
                      onTap: () {
                        context.push("/category-promotion");
                      },
                    ),

                    const SizedBox(height: 18),

                    _promotionCard(
                      context,
                      title: "Favorites",
                      subtitle: "View and manage your favorite promotions",
                      icon: Icons.favorite,
                      color1: Colors.purple.shade50,
                      color2: Colors.white,
                      iconColor: Colors.purple,
                      arrowColor: Colors.deepPurple,
                      badge: "156 saved promotions",
                      onTap: () {
                        context.push("/favorites");
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _smallMenu(Icons.history, "Recent"),
                        _smallMenu(Icons.description, "Templates"),
                        _smallMenu(Icons.star, "Top Deals"),
                        _smallMenu(Icons.card_giftcard, "Offers"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promotionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required Color iconColor,
    required Color arrowColor,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(colors: [color1, color2]),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.grey.withOpacity(.15),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(subtitle, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: arrowColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallMenu(IconData icon, String title) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
