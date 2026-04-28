import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('assn', 'lions') // 👈 filter added
        .order('person_name');

    return response;
  }
  Future<List<Map<String, dynamic>>> getcabinetProfiles() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('post_of_member', 'Cabinet') // 👈 filter added
        .order('person_name');

    return response;
  }

  Future<List<Map<String, dynamic>>> getrcProfiles() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('assn', 'lions')
        .eq('post_of_member', 'RC') // 👈 added condition
        .order('person_name');

    return response;
  }
  Future<List<Map<String, dynamic>>> getzcProfiles() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('assn', 'lions')
        .eq('post_of_member', 'ZC') // 👈 added condition
        .order('person_name');

    return response;
  }
  Future<List<Map<String, dynamic>>> getdcProfiles() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('assn', 'lions')
        .eq('post_of_member', 'DC') // 👈 added condition
        .order('person_name');

    return response;
  }
}
