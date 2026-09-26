import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/mock_city_catalog.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Helper to safely query candidate table names in order of preference
  Future<List<dynamic>> _fetchRows(List<String> candidateTables) async {
    for (final table in candidateTables) {
      try {
        final response = await _supabase.from(table).select();
        final List<dynamic> rows = response as List<dynamic>;
        return rows;
      } catch (e) {
        final err = e.toString();
        if (err.contains('PGRST205') || err.contains('42P01') || err.contains('not find the table')) {
          // Table does not exist in schema cache, try next candidate
          continue;
        }
        debugPrint('Supabase query error on "$table": $e');
      }
    }
    return [];
  }

  /// Fetches all 4 primary inventory tables directly from Supabase for [selectedCity]
  Future<Map<String, List<CatalogItem>>> fetchInventoryForCity(String selectedCity) async {
    final cityName = selectedCity.trim();
    final cityLower = cityName.toLowerCase();

    final Map<String, List<CatalogItem>> inventory = {
      'hotels': [],
      'places': [],
      'activities': [],
      'transport': [],
    };

    // 1. Query Hotels (candidate tables: operator_hotels, inventory_hotels, hotels)
    try {
      final rows = await _fetchRows(['operator_hotels', 'inventory_hotels', 'hotels']);
      final matching = rows.where((row) {
        if (row['is_active'] == false) return false;
        final c = (row['city'] ?? '').toString().toLowerCase();
        return c.contains(cityLower) || cityLower.contains(c);
      }).toList();

      final listToUse = matching.isNotEmpty ? matching : rows.where((r) => r['is_active'] != false).toList();
      debugPrint('Supabase [hotels]: Loaded ${listToUse.length} items for "$cityName" (Total in DB: ${rows.length})');

      inventory['hotels'] = listToUse
          .map((row) => CatalogItem.fromHotelJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error mapping hotels: $e');
    }

    // 2. Query Places (candidate tables: operator_places, inventory_places, places)
    try {
      final rows = await _fetchRows(['operator_places', 'inventory_places', 'places']);
      final matching = rows.where((row) {
        if (row['is_active'] == false) return false;
        final c = (row['city'] ?? '').toString().toLowerCase();
        final d = (row['description'] ?? '').toString().toLowerCase();
        return c.contains(cityLower) || cityLower.contains(c) || d.contains(cityLower);
      }).toList();

      final listToUse = matching.isNotEmpty ? matching : rows.where((r) => r['is_active'] != false).toList();
      debugPrint('Supabase [places]: Loaded ${listToUse.length} items for "$cityName" (Total in DB: ${rows.length})');

      inventory['places'] = listToUse
          .map((row) => CatalogItem.fromPlaceJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error mapping places: $e');
    }

    // 3. Query Activities (candidate tables: operator_activities, inventory_activities, activities)
    try {
      final rows = await _fetchRows(['operator_activities', 'inventory_activities', 'activities']);
      final matching = rows.where((row) {
        if (row['is_active'] == false) return false;
        final loc = (row['location'] ?? '').toString().toLowerCase();
        final title = (row['title'] ?? '').toString().toLowerCase();
        final type = (row['activity_type'] ?? '').toString().toLowerCase();
        return loc.contains(cityLower) || cityLower.contains(loc) || title.contains(cityLower) || type.contains(cityLower);
      }).toList();

      final listToUse = matching.isNotEmpty ? matching : rows.where((r) => r['is_active'] != false).toList();
      debugPrint('Supabase [activities]: Loaded ${listToUse.length} items for "$cityName" (Total in DB: ${rows.length})');

      inventory['activities'] = listToUse
          .map((row) => CatalogItem.fromActivityJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error mapping activities: $e');
    }

    // 4. Query Transport (candidate tables: operator_transport, inventory_transports, transport)
    try {
      final rows = await _fetchRows(['operator_transport', 'inventory_transports', 'inventory_transport', 'transports', 'transport']);
      final activeRows = rows.where((r) => r['is_active'] != false).toList();
      debugPrint('Supabase [transport]: Loaded ${activeRows.length} items (Total in DB: ${rows.length})');

      inventory['transport'] = activeRows
          .map((row) => CatalogItem.fromTransportJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error mapping transport: $e');
    }

    return inventory;
  }
}
