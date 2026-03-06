import 'package:celfonephonebookapp/Supabase/Supabase.dart';
import 'package:celfonephonebookapp/features/home/model/directory_model.dart';
import 'package:celfonephonebookapp/features/home/model/play_book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  String get userId => Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<List<DirectoryModel>> fetchTilesTitles() async {
    final response = await Supabase.instance.client
        .from('tiles_titles')
        .select('*')
        .order('id');

    return (response as List).map((e) => DirectoryModel.fromJson(e)).toList();
  }

  Future<List<dynamic>> getGroups() async {
    final response = await Supabase.instance.client
        .from('groups')
        .select()
        .eq('user_id', userId);

    return response;
  }

  Future<String> createOrGetGroup(String name) async {
    final existing = await Supabase.instance.client
        .from('groups')
        .select()
        .eq('user_id', userId)
        .eq('name', name)
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    final created = await Supabase.instance.client
        .from('groups')
        .insert({'user_id': userId, 'name': name})
        .select()
        .single();

    return created['id'];
  }

  Future<void> addFavorite(Map<String, dynamic> data) async {
    await Supabase.instance.client.from('favorites').insert(data);
  }

  Stream<List<Map<String, dynamic>>> favoriteStream() {
    return Supabase.instance.client
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((favorites) async {
          final groupIds = favorites.map((f) => f['group_id']).toSet().toList();

          if (groupIds.isEmpty) return favorites;

          final groups = await Supabase.instance.client
              .from('groups')
              .select()
              .inFilter('id', groupIds);

          final groupMap = {for (var g in groups) g['id']: g['name']};

          return favorites.map((fav) {
            return {...fav, 'group_name': groupMap[fav['group_id']]};
          }).toList();
        });
  }

  Future<void> deleteFavorite(String id) async {
    await Supabase.instance.client.from('favorites').delete().eq('id', id);
  }

  Future<List<String>> fetchHeaderImages() async {
    final response = await Supabase.instance.client
        .from('free_tier_shared_header_images')
        .select('image_url');

    final List data = response;

    return data.map((e) => e['image_url'] as String).toList();
  }

  Future<List<PlayBookModel>> fetchPlayBooks() async {
    final response = await Supabase.instance.client
        .from('playbooks')
        .select()
        .order('id');

    return (response as List).map((e) => PlayBookModel.fromJson(e)).toList();
  }

  static SupabaseClient get client => Supabase.instance.client;
}
