import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// 🔷 BACKGROUND BAR
          Container(height: 70, width: width, color: const Color(0xFF2E8CA8)),

          /// 🔵 CENTER SEARCH (Clickable)
          Positioned(
            bottom: 10,
            child: GestureDetector(
              onTap: () => onTap(2), // ✅ send index 2
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E8CA8),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 60,
                      color: currentIndex == 2
                          ? Colors.white
                          : Colors.black, // ✅ active highlight
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 14,
                        color: currentIndex == 2
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: currentIndex == 2
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔘 ITEMS
          Positioned(
            bottom: 8,
            child: SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildItem(Icons.home, "Home", 0),
                  _buildItem(Icons.campaign, "Promotions", 1),
                  const SizedBox(width: 60), // space for center
                  _buildItem(Icons.person_outline, "Partner", 3),
                  _buildItem(Icons.menu, "Menu", 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: isActive ? Colors.white : Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
