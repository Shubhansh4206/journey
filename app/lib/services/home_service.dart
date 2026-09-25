import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_group.dart';
import '../models/trip_request.dart';

class HomeService {
  final _supabase = Supabase.instance.client;

  Future<TripRequest?> getActiveTrip() async {
    // For dummy data, returning a mock TripRequest in 'reviewing_bids' phase
    // In a real scenario, this would be a query to Supabase:
    // return TripRequest.fromJson(await _supabase.from('trip_requests').select().eq('user_id', _supabase.auth.currentUser!.id).eq('status', 'reviewing_bids').single());
    return TripRequest(
      id: 'dummy-trip',
      groupId: 'dummy-group',
      destination: 'Udaipur',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      maxBudgetPerPax: 15000,
      status: 'reviewing_bids',
    );
  }

  Future<List<Map<String, dynamic>>> getOpenSquads() async {
    // Dummy open squads data with AI match score and dynamic pricing
    return [
      {
        'title': 'Manali Adventure',
        'matchScore': '94% Match',
        'originalPrice': '₹6k',
        'newPrice': '₹4.5k',
      },
      {
        'title': 'Goa Getaway',
        'matchScore': '88% Match',
        'originalPrice': '₹12k',
        'newPrice': '₹8.5k',
      },
      {
        'title': 'Kerala Backwaters',
        'matchScore': '92% Match',
        'originalPrice': '₹15k',
        'newPrice': '₹11k',
      },
    ];
  }
}
