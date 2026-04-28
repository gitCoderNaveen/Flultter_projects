import 'package:celfonephonebookapp/features/home/ui/custom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomNavBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/promotions');
              break;
            case 2:
              context.go('/search');
              break;
            case 3:
              context.go('/partner');
              break;
            case 4:
              context.go('/menu');
              break;
          }
        },
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/promotions')) return 1;
    if (location.startsWith('/partner')) return 3;
    if (location.startsWith('/menu')) return 4;
    return 0;
  }
}

BottomNavigationBarItem _buildItem(
  IconData icon,
  String label,
  int itemIndex,
  int currentIndex, {
  bool isSpecial = false,
}) {
  final isSelected = itemIndex == currentIndex;

  return BottomNavigationBarItem(
    label: label,
    icon: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isSelected && isSpecial ? 8 : 0),
      child: Icon(
        icon,
        size: isSelected
            ? (isSpecial ? 34 : 26) // 🔥 Bigger search icon
            : 22,
      ),
    ),
  );
}
