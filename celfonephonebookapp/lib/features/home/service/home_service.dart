import 'package:celfonephonebookapp/features/home/model/category_item_model.dart';
import 'package:celfonephonebookapp/features/home/model/directory_model.dart';
import 'package:celfonephonebookapp/features/home/model/popular_firm_model.dart';
import 'package:celfonephonebookapp/supabase/supabase.dart';

import '../../../core/services/supabase_service.dart';
import '../model/carousel_item.dart';

class HomeService {
  Future<List<CarouselItem>> fetchAds() async {
    final res = await SupabaseService.client
        .from('ads')
        .select('image_url, redirect_url');

    if (res == null || res.isEmpty) {
      return [];
    }

    return List<CarouselItem>.from(
      res.map(
        (e) => CarouselItem(
          imageUrl: e['image_url']?.toString() ?? '',
          redirectUrl: e['redirect_url']?.toString() ?? '',
        ),
      ),
    );
  }

  Future<List<DirectoryModel>> fetchDirectories() async {
    final response = await SupbaseService.client
        .from('online_directory')
        .select()
        .eq('is_active', true);

    return (response as List).map((e) => DirectoryModel.fromJson(e)).toList();
  }

  Future<List<CategoryItemModel>> fetchCategories() async {
    try {
      final res = await SupabaseService.client.from('tiles_titles').select();

      if (res == null || res.isEmpty) {
        return [];
      }

      return List<CategoryItemModel>.from(
        res.map((e) => CategoryItemModel.fromMap(e as Map<String, dynamic>)),
      );
    } catch (e) {
      return [];
    }
  }
}
