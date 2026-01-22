import '../../../core/services/supabase_service.dart';

class HomeService {
  Future<List<String>> fetchAds() async {
    final res = await SupabaseService.client.from('ads').select('image_url');

    return res.map<String>((e) => e['image_url']).toList();
  }

  Future<List<String>> fetchPopularFirms() async {
    final res = await SupabaseService.client
        .from('popular_firms')
        .select('name');

    return res.map<String>((e) => e['name']).toList();
  }
}
