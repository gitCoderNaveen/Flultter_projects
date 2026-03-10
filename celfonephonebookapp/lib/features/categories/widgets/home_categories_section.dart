import 'package:flutter/material.dart';
import '../controller/category_controller.dart';
import '../model/category_item.dart';
import '../view/category_section.dart';

class HomeCategoriesSection extends StatefulWidget {
  const HomeCategoriesSection({super.key});

  @override
  State<HomeCategoriesSection> createState() => _HomeCategoriesSectionState();
}

class _HomeCategoriesSectionState extends State<HomeCategoriesSection> {
  final controller = CategoryController();

  static final demoB2C = [
    CategoryItem(title: 'Hospital', keywords: 'hospital'),
    CategoryItem(title: 'Hotels', keywords: 'hotel'),
    CategoryItem(title: 'Colleges', keywords: 'college'),
    CategoryItem(title: 'Travel', keywords: 'travel'),
    CategoryItem(title: 'Doctors', keywords: 'doctor'),
    CategoryItem(title: 'Shops', keywords: 'shop'),
    CategoryItem(title: 'Parlour', keywords: 'parlour'),
  ];

  static final demoB2B = [
    CategoryItem(title: 'Chemical', keywords: 'chemical'),
    CategoryItem(title: 'Electrical', keywords: 'electrical'),
    CategoryItem(title: 'Steel', keywords: 'steel'),
    CategoryItem(title: 'CNC', keywords: 'cnc'),
    CategoryItem(title: 'Electronics', keywords: 'electronics'),
    CategoryItem(title: 'Builder', keywords: 'builder'),
    CategoryItem(title: 'Hydraulic', keywords: 'hydraulic'),
  ];

  @override
  void initState() {
    super.initState();
    controller.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategorySection(
          title: "B2C Categories",
          items: controller.b2cCategories,
          isLoading: controller.isLoading,
          demoItems: demoB2C,
          onMoreTap: () {},
        ),
        CategorySection(
          title: "B2B Categories",
          items: controller.b2bCategories,
          isLoading: controller.isLoading,
          demoItems: demoB2B,
          onMoreTap: () {},
        ),
      ],
    );
  }
}
