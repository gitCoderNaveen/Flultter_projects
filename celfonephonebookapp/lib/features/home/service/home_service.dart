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

  Future<List<String>> fetchPopularFirms() async {
    final res = await SupabaseService.client
        .from('popular_firms')
        .select('name');

    return List<String>.from(res.map((e) => e['name'].toString()));
  }
}
