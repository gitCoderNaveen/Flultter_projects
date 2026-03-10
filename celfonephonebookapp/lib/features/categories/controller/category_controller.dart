import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/category_item.dart';

class CategoryController {
  final _supabase = Supabase.instance.client;

  final ValueNotifier<List<CategoryItem>> b2cCategories = ValueNotifier([]);
  final ValueNotifier<List<CategoryItem>> b2bCategories = ValueNotifier([]);

  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  Future<void> loadCategories() async {
    try {
      final response = await _supabase.from('tiles_titles').select();

      final items = (response as List)
          .map((e) => CategoryItem.fromMap(e))
          .toList();

      b2cCategories.value = items.where((c) => c.isB2C).toList();
      b2bCategories.value = items.where((c) => c.isB2B).toList();
    } catch (e) {
      debugPrint("Category error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
