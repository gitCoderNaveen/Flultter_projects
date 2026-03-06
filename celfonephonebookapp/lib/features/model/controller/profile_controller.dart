import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profile_model.dart';
import '../model/product_model.dart';

class ProfileController {
  final supabase = Supabase.instance.client;

  /// get profile
  Future<ProfileModel?> getProfile(String profileId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', profileId)
        .single();

    return ProfileModel.fromMap(response);
  }

  /// get products
  Future<List<ProductModel>> getProducts(String profileId) async {
    final response = await supabase
        .from('product_table')
        .select()
        .eq('profile_id', profileId);

    return (response as List).map((e) => ProductModel.fromMap(e)).toList();
  }
}
