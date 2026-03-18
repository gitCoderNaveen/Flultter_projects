
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/db_tables.dart';
import '../../../core/constants/profile_fields.dart';

class SearchService {
  final _db = Supabase.instance.client;

  Future<List<dynamic>> fetchAll() async {
    return await _db
        .from(DbTables.profiles)
        .select()
        .order(ProfileFields.isPrime, ascending: false)
        .order(ProfileFields.priority, ascending: false);
  }

  Future<List<dynamic>> searchByName(String q) async {
    return await _db
        .from(DbTables.profiles)
        .select()
        .or(
          '${ProfileFields.businessName}.ilike.%$q%,'
          '${ProfileFields.personName}.ilike.%$q%',
        )
        .order(ProfileFields.isPrime, ascending: false);
  }

  Future<List<dynamic>> searchByKeywords(String q) async {
    return await _db
        .from(DbTables.profiles)
        .select()
        .ilike(ProfileFields.keywords, '%$q%')
        .order(ProfileFields.isPrime, ascending: false);
  }

  Future<List<dynamic>> searchByLetter(String letter) async {
    return await _db
        .from(DbTables.profiles)
        .select()
        .ilike(ProfileFields.businessName, '${letter.toUpperCase()}%')
        .order(ProfileFields.isPrime, ascending: false);
  }

  Future<List<dynamic>> searchGeneral(String query) async {
    return await _db
        .from(DbTables.profiles)
        .select()
        .or(
          '${ProfileFields.businessName}.ilike.%$query%,'
          '${ProfileFields.personName}.ilike.%$query%,'
          '${ProfileFields.keywords}.ilike.%$query%',
        )
        .order(ProfileFields.isPrime, ascending: false)
        .order(ProfileFields.priority, ascending: false);
  }
}
