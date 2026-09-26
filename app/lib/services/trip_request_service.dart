import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_city_catalog.dart';
import '../models/trip_request.dart';

class TripRequestService {
  final _supabase = Supabase.instance.client;

  Future<TripRequest?> create({
    String? groupId,
    String? assignedGroupName,
    required TripCartDraft draft,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      // Extract item UUIDs segregated by category
      final hotelUuids = <String>[];
      final placeUuids = <String>[];
      final activityUuids = <String>[];
      final transportUuids = <String>[];

      // Regex to ensure valid UUID format for PostgreSQL UUID[] column
      final uuidRegex = RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

      for (final item in draft.items) {
        if (!uuidRegex.hasMatch(item.id)) continue;

        switch (item.type.toLowerCase()) {
          case 'hotel':
            hotelUuids.add(item.id);
            break;
          case 'place':
            placeUuids.add(item.id);
            break;
          case 'activity':
            activityUuids.add(item.id);
            break;
          case 'transport':
            transportUuids.add(item.id);
            break;
        }
      }

      final payload = <String, dynamic>{
        'customer_id': ?currentUserId,
        'group_id': ?groupId,
        'destination': draft.city.name,
        'trip_mode': draft.isSolo ? 'Solo Journey' : 'Group Squad',
        'assigned_group_name': assignedGroupName ??
            (draft.isSolo ? 'Solo Explorer' : 'Travel Squad'),
        'start_date': draft.startDate.toIso8601String().split('T').first,
        'end_date': draft.endDate.toIso8601String().split('T').first,
        'per_person_budget': draft.budget,
        'estimated_mock_total': draft.estimatedTotal,
        'selected_hotels': hotelUuids,
        'selected_places': placeUuids,
        'selected_activities': activityUuids,
        'selected_transport': transportUuids,
        'status': 'pending',
      };

      debugPrint('🚀 [TripRequestService.create] Sending payload: $payload');

      final row = await _supabase
          .from('trip_requests')
          .insert(payload)
          .select()
          .single();

      debugPrint('✅ [TripRequestService.create] Created trip_request: $row');
      return TripRequest.fromJson(row);
    } catch (e, stack) {
      debugPrint('❌ [TripRequestService.create] Error: $e\n$stack');
      return null;
    }
  }
}

