import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final supabase = Supabase.instance.client;

class CategorywiseProServices {
  Future<List<String>> getSuggestions(String column, String query) async {
    final response = await supabase
        .from('profiles')
        .select(column)
        .ilike(column, '%$query%');

    final keywords = <String>{};

    for (var row in response) {
      final raw = row[column]?.toString() ?? "";

      final split = raw.split(",");

      for (var k in split) {
        final keyword = k.trim();

        if (keyword.toLowerCase().contains(query.toLowerCase())) {
          keywords.add(keyword);
        }
      }
    }

    final list = keywords.toList();

    list.sort();

    return list;
  }

  Future<List<Map<String, dynamic>>> searchBusinesses(
    String category,
    String city,
  ) async {
    final data = await supabase
        .from('profiles')
        .select('id, business_name, keywords, mobile_number, city')
        .ilike('keywords', '%$category%')
        .ilike('city', '%$city%');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<bool> sendSMS(List<String> numbers, String message) async {
    if (numbers.isEmpty) return false;

    final recipients = numbers.join(',');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: recipients,
      queryParameters: {'body': message},
    );

    bool launched = await launchUrl(
      smsUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      final fallbackUrl =
          "sms:$recipients?body=${Uri.encodeComponent(message)}";

      launched = await launchUrl(
        Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication,
      );
    }

    return launched;
  }
}
