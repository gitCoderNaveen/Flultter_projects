import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPresidents() async {
    final response = await supabase
        .from('presidents_table')
        .select()
        .order('created_at', ascending: true)
        .limit(3);

    return response;
  }

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final response = await supabase
        .from('profiles')
        .select()
        .order('person_name');

    return response;
  }
}