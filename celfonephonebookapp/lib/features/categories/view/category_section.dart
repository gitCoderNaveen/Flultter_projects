import 'package:flutter/material.dart';
import '../model/category_item.dart';
import 'category_tile.dart';
import 'more_category_tile.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final ValueNotifier<List<CategoryItem>> items;
  final ValueNotifier<bool> isLoading;
  final List<CategoryItem> demoItems;
  final VoidCallback onMoreTap;

  const CategorySection({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.demoItems,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (_, loading, __) {
              if (loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ValueListenableBuilder(
                valueListenable: items,
                builder: (_, list, __) {
                  final displayItems = (list.isEmpty ? demoItems : list)
                      .take(7)
                      .toList();

                  displayItems.add(
                    CategoryItem(title: "More", keywords: '', isMore: true),
                  );

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.88,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                    itemCount: displayItems.length,
                    itemBuilder: (_, i) {
                      final cat = displayItems[i];

                      return cat.isMore
                          ? MoreCategoryTile(title: "More", onTap: onMoreTap)
                          : CategoryTile(item: cat);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
