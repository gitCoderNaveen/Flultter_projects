import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NearbyPromotionService {
  final SupabaseClient _supabase = SupabaseService.client;

  static const String sentNumbersKey = "sent_numbers_list";

  /// SEARCH PROFILES FROM SUPABASE
  Future<List<Map<String, dynamic>>> searchProfiles({
    required String pincode,
    required String category,
  }) async {
    try {
      String prefix = "";
      String column = "";

      switch (category) {
        case "Gents":
          prefix = "Mr.";
          column = "person_prefix";
          break;

        case "Ladies":
          prefix = "Ms.";
          column = "person_prefix";
          break;

        case "Firms":
          prefix = "M/s.";
          column = "business_prefix";
          break;

        default:
          throw Exception("Invalid category");
      }

      final response = await _supabase
          .from("profiles")
          .select()
          .eq("pincode", pincode)
          .ilike(column, "$prefix%");

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception("Search failed: $e");
    }
  }

  /// GET SENT NUMBERS FROM LOCAL STORAGE
  Future<List<String>> getSentNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final list = prefs.getStringList(sentNumbersKey);

      return list ?? [];
    } catch (e) {
      return [];
    }
  }

  /// SAVE SENT NUMBERS
  Future<void> saveSentNumbers(List<String> numbers) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(sentNumbersKey, numbers);
    } catch (e) {
      throw Exception("Failed to save sent numbers");
    }
  }

  /// ADD SINGLE SENT NUMBER
  Future<void> addSentNumber(String number) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final existing = prefs.getStringList(sentNumbersKey) ?? [];

      if (!existing.contains(number)) {
        existing.add(number);
        await prefs.setStringList(sentNumbersKey, existing);
      }
    } catch (e) {
      throw Exception("Failed to add sent number");
    }
  }

  /// ADD MULTIPLE SENT NUMBERS
  Future<void> addMultipleSentNumbers(List<String> numbers) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final existing = prefs.getStringList(sentNumbersKey) ?? [];

      for (final number in numbers) {
        if (!existing.contains(number)) {
          existing.add(number);
        }
      }

      await prefs.setStringList(sentNumbersKey, existing);
    } catch (e) {
      throw Exception("Failed to add multiple sent numbers");
    }
  }

  /// CHECK IF NUMBER ALREADY SENT
  Future<bool> isNumberSent(String number) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final existing = prefs.getStringList(sentNumbersKey) ?? [];

      return existing.contains(number);
    } catch (e) {
      return false;
    }
  }

  /// CLEAR ALL SENT DATA (Optional utility)
  Future<void> clearSentNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(sentNumbersKey);
    } catch (e) {
      throw Exception("Failed to clear sent numbers");
    }
  }
}
