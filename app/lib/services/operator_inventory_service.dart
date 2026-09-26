import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_city_catalog.dart';

class OperatorInventoryService {
  final _supabase = Supabase.instance.client;

  /// Fetches operator hotels, activities, places, and transport for a specific city from Supabase
  Future<Map<String, List<CatalogItem>>> fetchInventoryForCity(String cityName) async {
    final Map<String, List<CatalogItem>> inventory = {
      'hotels': [],
      'activities': [],
      'places': [],
      'transport': [],
    };

    final cityQuery = cityName.trim().toLowerCase();

    // 1. Fetch Hotels from operator_hotels
    try {
      final response = await _supabase
          .from('operator_hotels')
          .select()
          .eq('is_active', true);

      final List<dynamic> rows = response as List<dynamic>;
      final matching = rows.where((row) {
        final c = (row['city'] ?? '').toString().toLowerCase();
        return c.contains(cityQuery) || cityQuery.contains(c);
      }).toList();

      final listToUse = matching.isNotEmpty ? matching : rows;

      inventory['hotels'] = listToUse.map((row) {
        final star = row['star_rating'];
        final address = row['address'] ?? row['city'] ?? '';
        final price = (row['contracted_rate_per_night'] as num?)?.toDouble() ?? 3500.0;
        final starStr = star != null ? '$star★ • ' : '';

        return CatalogItem(
          id: row['id']?.toString() ?? UniqueKey().toString(),
          name: row['name']?.toString() ?? 'Hotel Stay',
          type: 'hotel',
          price: price,
          subtitle: '$starStr$address'.trim(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching operator_hotels from Supabase: $e');
    }

    // 2. Fetch Places from operator_places
    try {
      final response = await _supabase
          .from('operator_places')
          .select()
          .eq('is_active', true);

      final List<dynamic> rows = response as List<dynamic>;
      final matching = rows.where((row) {
        final c = (row['city'] ?? '').toString().toLowerCase();
        return c.contains(cityQuery) || cityQuery.contains(c);
      }).toList();

      final listToUse = matching.isNotEmpty ? matching : rows;

      inventory['places'] = listToUse.map((row) {
        final duration = row['recommended_duration_minutes'];
        final desc = row['description']?.toString() ?? '';
        final price = (row['entry_fee_per_person'] as num?)?.toDouble() ?? 0.0;
        final durStr = duration != null ? '$duration mins • ' : '';

        return CatalogItem(
          id: row['id']?.toString() ?? UniqueKey().toString(),
          name: row['name']?.toString() ?? 'Attraction',
          type: 'place',
          price: price,
          subtitle: desc.isNotEmpty ? desc : '${durStr}Scenic landmark',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching operator_places from Supabase: $e');
    }

    // 3. Fetch Activities from operator_activities
    try {
      final response = await _supabase
          .from('operator_activities')
          .select()
          .eq('is_active', true);

      final List<dynamic> rows = response as List<dynamic>;
      final matching = rows.where((row) {
        final loc = (row['location'] ?? '').toString().toLowerCase();
        final title = (row['title'] ?? '').toString().toLowerCase();
        return loc.contains(cityQuery) || cityQuery.contains(loc) || title.contains(cityQuery);
      }).toList();

      final listToUse = matching.isNotEmpty ? matching : rows;

      inventory['activities'] = listToUse.map((row) {
        final duration = row['duration_minutes'];
        final loc = row['location']?.toString() ?? row['activity_type']?.toString() ?? '';
        final price = (row['cost_per_person'] as num?)?.toDouble() ?? 1500.0;
        final durStr = duration != null ? '$duration mins • ' : '';

        return CatalogItem(
          id: row['id']?.toString() ?? UniqueKey().toString(),
          name: row['title']?.toString() ?? 'Adventure Activity',
          type: 'activity',
          price: price,
          subtitle: '$durStr$loc'.trim(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching operator_activities from Supabase: $e');
    }

    // 4. Fetch Transport from operator_transport
    try {
      final response = await _supabase
          .from('operator_transport')
          .select()
          .eq('is_active', true);

      final List<dynamic> rows = response as List<dynamic>;

      inventory['transport'] = rows.map((row) {
        final capacity = row['capacity_passengers'] ?? 4;
        final vendor = row['vendor_company_name']?.toString() ?? 'AC Private Transfer';
        final costDay = (row['cost_per_day'] as num?)?.toDouble() ?? 0.0;
        final costKm = (row['cost_per_km'] as num?)?.toDouble() ?? 0.0;
        final price = costDay > 0 ? costDay : (costKm > 0 ? costKm * 100 : 2500.0);

        return CatalogItem(
          id: row['id']?.toString() ?? UniqueKey().toString(),
          name: row['vehicle_type']?.toString() ?? 'Private Vehicle',
          type: 'transport',
          price: price,
          subtitle: '$capacity Seats • $vendor',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching operator_transport from Supabase: $e');
    }

    return inventory;
  }
}
