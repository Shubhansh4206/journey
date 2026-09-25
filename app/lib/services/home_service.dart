import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/solo_community.dart';
import '../models/trip_request.dart';

class HomeService {
  final _supabase = Supabase.instance.client;

  Future<Stream<List<TripRequest>>> getActiveTripStream() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    try {
      final members = await _supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', user.id);

      final groupIds =
          (members as List).map((e) => e['group_id'].toString()).toList();

      return _supabase.from('trip_requests').stream(primaryKey: ['id']).map(
        (events) {
          final requests = events.map((e) => TripRequest.fromJson(e)).toList();
          if (groupIds.isNotEmpty) {
            return requests.where((r) => groupIds.contains(r.groupId)).toList();
          }
          return requests;
        },
      );
    } catch (e) {
      debugPrint('getActiveTripStream group_members error: $e');
      return _supabase.from('trip_requests').stream(primaryKey: ['id']).map(
        (events) {
          return events.map((e) => TripRequest.fromJson(e)).toList();
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getOpenSquads({
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabase
          .from('groups')
          .select('*, trip_requests(*)')
          .eq('open_to_solos', true);

      final list = List<Map<String, dynamic>>.from(response as List);

      final mapped = list.map((group) {
        final requests = List<Map<String, dynamic>>.from(
          group['trip_requests'] as List? ?? [],
        );
        Map<String, dynamic>? request;
        if (destination != null && destination.isNotEmpty) {
          final destLower = destination.toLowerCase();
          for (final r in requests) {
            final dest = (r['destination'] ?? '').toString().toLowerCase();
            if (dest.contains(destLower) || destLower.contains(dest)) {
              request = r;
              break;
            }
          }
        } else if (requests.isNotEmpty) {
          request = requests.first;
        }

        DateTime? reqStart;
        DateTime? reqEnd;
        if (request != null) {
          reqStart = DateTime.tryParse(request['start_date']?.toString() ?? '');
          reqEnd = DateTime.tryParse(request['end_date']?.toString() ?? '');
        }

        final destName =
            request?['destination'] ?? group['name'] ?? 'Open squad';
        final maxBudget = request != null
            ? (request['max_budget_per_pax'] as num?)?.toDouble() ?? 10000.0
            : 10000.0;

        return {
          'id': group['id'],
          'name': group['name'] ?? destName,
          'destination': destName,
          'startDate': reqStart,
          'endDate': reqEnd,
          'maxBudget': maxBudget,
          'matchScore': '92% Match',
        };
      }).toList();

      var filtered = mapped;
      if (destination != null && destination.isNotEmpty) {
        final destLower = destination.toLowerCase();
        filtered = filtered.where((s) {
          final dest = (s['destination'] ?? '').toString().toLowerCase();
          final name = (s['name'] ?? '').toString().toLowerCase();
          return dest.contains(destLower) ||
              destLower.contains(dest) ||
              name.contains(destLower);
        }).toList();
      }

      if (startDate != null && endDate != null) {
        filtered = filtered.where((s) {
          final reqStart = s['startDate'] as DateTime?;
          final reqEnd = s['endDate'] as DateTime?;
          if (reqStart == null || reqEnd == null) return true;
          return !reqEnd.isBefore(startDate) && !reqStart.isAfter(endDate);
        }).toList();
      }

      return filtered;
    } catch (e) {
      debugPrint('getOpenSquads error: $e');
      return [];
    }
  }

  Future<List<Community>> getCommunities({
    String? destination,
    DateTime? around,
  }) async {
    try {
      final response = await _supabase.from('communities').select();
      var communities = List<Map<String, dynamic>>.from(response as List)
          .map(Community.fromJson)
          .toList();

      if (destination != null && destination.isNotEmpty) {
        final destLower = destination.toLowerCase();
        communities = communities
            .where((c) => c.destination.toLowerCase().contains(destLower))
            .toList();
      }

      if (around != null) {
        final monthKey =
            '${around.year}-${around.month.toString().padLeft(2, '0')}';
        final monthName = _monthName(around.month);
        communities = communities.where((c) {
          final m = c.travelMonth.toLowerCase();
          return m.contains(monthKey) ||
              m.contains(monthName.toLowerCase()) ||
              m.contains(around.year.toString());
        }).toList();
      }

      return communities;
    } catch (e) {
      debugPrint('getCommunities error: $e');
      return [];
    }
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}
