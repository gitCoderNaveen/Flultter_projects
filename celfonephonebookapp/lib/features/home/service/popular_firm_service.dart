import 'package:celfonephonebookapp/Supabase/Supabase.dart';
import 'package:celfonephonebookapp/features/home/model/popular_firm_model.dart';

class PopularFirmService {
  static Future<List<PopularFirmModel>> getPopularFirms() async {
    final res = await SupbaseService.client
        .from('popular_firms')
        .select()
        .eq('is_active', true);

    return (res as List).map((e) => PopularFirmModel.fromJson(e)).toList();
  }
}
