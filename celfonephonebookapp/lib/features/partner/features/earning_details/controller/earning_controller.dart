import 'package:celfonephonebookapp/features/partner/features/earning_details/model/earning_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EarningController {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchLifetimeStats() async {
    final user = supabase.auth.currentUser;
    if (user == null) return {'count': 0, 'earn': 0};

    try {
      final sProfile = await supabase
          .from('s_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final stats = await supabase
          .from('data_entry_table')
          .select('count, earnings')
          .eq('user_id', sProfile['id']);

      int totalCount = 0;
      int totalEarn = 0;

      for (var row in stats) {
        totalCount += (row['count'] as int? ?? 0);
        totalEarn += (row['earnings'] as int? ?? 0);
      }

      return {'count': totalCount, 'earn': totalEarn};
    } catch (_) {
      return {'count': 0, 'earn': 0};
    }
  }

  Future<List<EarningModel>> fetchFilteredActivities({
    required String selectedPeriod,
    required DateTime selectedDate,
    required DateTime viewDate,
    DateTimeRange? customRange,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final sProfile = await supabase
          .from('s_profiles')
          .select('id')
          .eq('user_id', user.id)
          .single();

      DateTime start;
      DateTime end;

      if (selectedPeriod == 'Weekly') {
        start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      } else if (selectedPeriod == 'Monthly') {
        start = DateTime(selectedDate.year, selectedDate.month, 1);
        end = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);
      } else {
        if (customRange == null) return [];
        start = customRange.start;
        end = customRange.end.add(const Duration(hours: 23, minutes: 59));
      }

      final res = await supabase
          .from('data_entry_name')
          .select()
          .eq('user_id', sProfile['id'])
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => EarningModel.fromMap(e))
          .toList();
    } catch (_) {
      return [];
    }
  }
}