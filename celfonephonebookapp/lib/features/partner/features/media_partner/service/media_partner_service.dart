import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/media_partner_model.dart';

class MediaPartnerService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadImage(File file, String userId) async {
    final fileExt = file.path.split('.').last;
    final fileName =
        '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await supabase.storage.from('partner').upload(fileName, file);

    return supabase.storage.from('partner').getPublicUrl(fileName);
  }

  Future<void> insertProfile(MediaPartnerModel model) async {
    await supabase.from('profiles').insert(model.toJson());
  }

  Future<Map<String, dynamic>?> checkMobile(String mobile) async {
    return await supabase
        .from('profiles')
        .select('person_name,business_name')
        .eq('mobile_number', mobile)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> checkLandline(String landline) async {
    return await supabase
        .from('profiles')
        .select('person_name,business_name')
        .eq('landline', landline)
        .maybeSingle();
  }
}
