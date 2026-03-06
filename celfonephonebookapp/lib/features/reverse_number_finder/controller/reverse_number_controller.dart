import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import '../model/reverse_number_model.dart';

class ReverseNumberController {
  final supabase = SupabaseService.client;

  Future<List<ReverseNumberModel>> findByMobile(String mobile) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('mobile_number', mobile);

    return (response as List)
        .map((e) => ReverseNumberModel.fromJson(e))
        .toList();
  }
}
