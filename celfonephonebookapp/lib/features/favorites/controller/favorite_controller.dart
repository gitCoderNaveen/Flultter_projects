import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/favorites/model/favorited_model.dart';

class FavoriteController {
  final SupabaseService _service = SupabaseService();

  Future<void> addToFavorite({
    required String groupName,
    required String businessName,
    required String personName,
    required String mobileNumber,
  }) async {
    final groupId = await _service.createOrGetGroup(groupName);

    final favorite = FavoriteModel(
      businessName: businessName,
      personName: personName,
      mobileNumber: mobileNumber,
      groupId: groupId,
    );

    await _service.addFavorite(favorite.toJson(_service.userId));
  }

  Stream<List<Map<String, dynamic>>> favoritesStream() {
    return _service.favoriteStream();
  }

  Future<void> deleteFavorite(String id) async {
    await _service.deleteFavorite(id);
  }
}
