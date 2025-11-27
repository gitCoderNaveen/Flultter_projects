import 'package:supabase_flutter/supabase_flutter.dart';

class DataService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchRootKeywords() async {
    final res = await _client.from('root_keywords').select();
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> createRootKeyword(String keywords) async {
    final user = _client.auth.currentUser;
    await _client.from('root_keywords').insert({
      'user_id': user!.id,
      'keywords': keywords,
    });
  }

  Future<List<Map<String, dynamic>>> fetchKeywordsForRoot(String id) async {
    final res = await _client.from('keywords').select().eq('root_keyword_id', id);
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> createKeyword(String rootId, String keyword) async {
    await _client.from('keywords').insert({
      'root_keyword_id': rootId,
      'keyword': keyword,
    });
  }

  Future<List<Map<String, dynamic>>> fetchRootProducts() async {
    final res = await _client.from('root_products').select();
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> createRootProduct(String category) async {
    final user = _client.auth.currentUser;
    await _client.from('root_products').insert({
      'user_id': user!.id,
      'category': category,
    });
  }

  Future<void> createProduct(String rootId, String name, String desc,
      {String? imageUrl}) async {
    await _client.from('products').insert({
      'root_product_id': rootId,
      'product_name': name,
      'product_description': desc,
      'product_image_url': imageUrl,
    });
  }

  Future<List<Map<String, dynamic>>> fetchCarousel() async {
    final res = await _client.from('carousel_table').select();
    return (res.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> addCarouselImage(String imageUrl) async {
    final user = _client.auth.currentUser;
    await _client.from('carousel_table').insert({
      'user_id': user!.id,
      'image_url': imageUrl,
    });
  }
}
