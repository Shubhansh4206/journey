import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_city_catalog.dart';
import '../models/trip_request.dart';

class TripRequestService {
  final _supabase = Supabase.instance.client;

  Future<TripRequest?> create({
    required String groupId,
    required TripCartDraft draft,
  }) async {
    try {
      final row = await _supabase.from('join_requests').insert({
        'group_id': groupId,
        'destination': draft.city.name,
        'start_date': draft.startDate.toIso8601String().split('T').first,
        'end_date': draft.endDate.toIso8601String().split('T').first,
        'max_budget_per_pax': draft.budget,
        'requested_cart_items':
            draft.items.map((item) => item.toCartJson()).toList(),
        'status': 'broadcasting',
      }).select().single();

      return TripRequest.fromJson(row);
    } catch (e) {
      debugPrint('TripRequestService.create error: $e');
      return null;
    }
  }
}
