import 'package:celfonephonebookapp/features/promotions/features/categorywisepromotions/ui/categorywise_pro_page.dart';
import 'package:celfonephonebookapp/features/promotions/features/nearbypromotions/ui/nearbypromotion_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controller/promotion_controller.dart';

class PromotionsPage extends StatelessWidget {
  PromotionsPage({super.key});

  final PromotionController controller = PromotionController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            backgroundColor: const Color(0xFF1F8EB6),
            title: const _HeaderRow(collapsed: true),
            centerTitle: true,
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _card(
                  context,
                  "Nearby Promotion",
                  "Reach customers in your immediate radius",
                  Icons.explore,
                  () => context.push('/nearby-promotion'),
                ),

                _card(
                  context,
                  "Categorywise Promotion",
                  "Target specific industries",
                  Icons.view_module,
                  () => context.push('/category-promotion'),
                ),
                _card(
                  context,
                  "Favorites",
                  "View your favorite promotions",
                  Icons.favorite,
                  () => context.push("/favorites"),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final bool collapsed;
  const _HeaderRow({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final color = collapsed ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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

                  const SizedBox(height: 2),

                  const Text(
                    "Connects For Growth",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
