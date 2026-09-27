import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/itinerary_node_model.dart';
import '../models/quotation_model.dart';

class QuotationNegotiationService {
  static final QuotationNegotiationService _instance =
      QuotationNegotiationService._internal();
  factory QuotationNegotiationService() => _instance;
  QuotationNegotiationService._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  // ── 1. Stream Quotation by Trip Request ID (Realtime) ─────────────────────
  Stream<QuotationModel?> streamQuotationByTripRequestId(String tripRequestId) {
    print('📡 [STREAM_QUOTE] Realtime stream initiated for trip_request_id: "$tripRequestId"');
    return _supabase
        .from('quotations')
        .stream(primaryKey: ['id'])
        .eq('trip_request_id', tripRequestId)
        .map((rows) {
          print('📡 [STREAM_QUOTE] Event on quotations table! Rows count: ${rows.length}');
          if (rows.isEmpty) {
            print('⚠️ [STREAM_QUOTE] No quotation found for trip_request_id: "$tripRequestId"');
            return null;
          }
          final sorted = List<Map<String, dynamic>>.from(rows);
          sorted.sort((a, b) => (b['created_at'] ?? '')
              .toString()
              .compareTo((a['created_at'] ?? '').toString()));
          final quote = QuotationModel.fromJson(sorted.first);
          print('✅ [STREAM_QUOTE] Parsed quotation: ID="${quote.id}", status="${quote.status}", total=₹${quote.totalFinalPrice}, ppp=₹${quote.perPersonPrice}');
          return quote;
        })
        .handleError((err) {
          print('❌ [STREAM_QUOTE] Realtime stream error: $err');
          print('💡 [SUPABASE_FIX] To fix this, run these 4 lines in your Supabase SQL Editor:');
          print('   ALTER PUBLICATION supabase_realtime ADD TABLE public.quotations;');
          print('   ALTER PUBLICATION supabase_realtime ADD TABLE public.itinerary_nodes;');
          print('   ALTER TABLE public.quotations REPLICA IDENTITY FULL;');
          print('   ALTER TABLE public.itinerary_nodes REPLICA IDENTITY FULL;');
          return null;
        });
  }

  // ── 2. Stream Quotation by ID (Realtime) ───────────────────────────────────
  Stream<QuotationModel?> streamQuotation(String quotationId) {
    print('📡 [STREAM_QUOTE] Realtime stream initiated for quotation_id: "$quotationId"');
    return _supabase
        .from('quotations')
        .stream(primaryKey: ['id'])
        .eq('id', quotationId)
        .map((rows) {
          print('📡 [STREAM_QUOTE] Event on quotations table for ID! Rows count: ${rows.length}');
          if (rows.isEmpty) {
            print('⚠️ [STREAM_QUOTE] No row found for quotationId: "$quotationId"');
            return null;
          }
          final quote = QuotationModel.fromJson(rows.first);
          print('✅ [STREAM_QUOTE] Parsed quotation: ID="${quote.id}", status="${quote.status}", total=₹${quote.totalFinalPrice}');
          return quote;
        })
        .handleError((err) {
          print('❌ [STREAM_QUOTE] Error in quotations stream: $err');
          return null;
        });
  }

  // ── 3. Stream Itinerary Nodes for a Quotation (Realtime) ───────────────────
  Stream<List<ItineraryNodeModel>> streamItineraryNodes(String quotationId) {
    print('📡 [STREAM_NODES] Realtime stream initiated for itinerary_nodes with quotation_id: "$quotationId"');
    return _supabase
        .from('itinerary_nodes')
        .stream(primaryKey: ['id'])
        .eq('quotation_id', quotationId)
        .map((rows) {
          print('📡 [STREAM_NODES] Event on itinerary_nodes! Raw rows count: ${rows.length}');
          final nodes = rows
              .map((r) => ItineraryNodeModel.fromJson(r))
              .toList();
          nodes.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          print('✅ [STREAM_NODES] Parsed and sorted ${nodes.length} nodes from database');
          for (int i = 0; i < nodes.length; i++) {
            print('   🔹 Node $i: [${nodes[i].nodeType}] "${nodes[i].title}" (finalPrice: ₹${nodes[i].finalPrice}, order: ${nodes[i].orderIndex})');
          }
          return nodes;
        })
        .handleError((err) {
          print('❌ [STREAM_NODES] Error in itinerary_nodes stream: $err');
          return <ItineraryNodeModel>[];
        });
  }

  // ── 4. Fetch Quotation by Trip Request ID from Database ───────────────────
  Future<QuotationModel?> getQuotationByTripRequestId(String tripRequestId) async {
    try {
      print('🔍 [DB_READ] Querying quotations table where trip_request_id == "$tripRequestId"');
      final res = await _supabase
          .from('quotations')
          .select()
          .eq('trip_request_id', tripRequestId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      print('🔍 [DB_READ] Database response: $res');
      if (res != null) {
        final quote = QuotationModel.fromJson(res);
        print('✅ [DB_READ] Found quotation in database: ID="${quote.id}", title="${quote.title}", status="${quote.status}", total=₹${quote.totalFinalPrice}');
        return quote;
      }
      print('⚠️ [DB_READ] No quotation record exists for trip_request_id: "$tripRequestId"');
      return null;
    } catch (e, stack) {
      print('❌ [DB_READ] Error querying quotations for trip_request_id "$tripRequestId": $e\n$stack');
      return null;
    }
  }

  // ── 5. Fetch Single Quotation by ID from Database ──────────────────────────
  Future<QuotationModel?> getQuotation(String quotationId) async {
    try {
      print('🔍 [DB_READ] Querying quotations table where id == "$quotationId"');
      final res = await _supabase
          .from('quotations')
          .select()
          .eq('id', quotationId)
          .maybeSingle();

      print('🔍 [DB_READ] Database response: $res');
      if (res != null) {
        final quote = QuotationModel.fromJson(res);
        print('✅ [DB_READ] Found quotation by ID: "${quote.id}", title="${quote.title}", status="${quote.status}"');
        return quote;
      }
      print('⚠️ [DB_READ] Quotation with ID "$quotationId" not found in database.');
      return null;
    } catch (e, stack) {
      print('❌ [DB_READ] Error fetching quotation ID "$quotationId": $e\n$stack');
      return null;
    }
  }

  // ── 6. Fetch Itinerary Nodes from Database ─────────────────────────────────
  Future<List<ItineraryNodeModel>> getItineraryNodes(String quotationId) async {
    try {
      print('🔍 [DB_READ] Querying itinerary_nodes table where quotation_id == "$quotationId"');
      final res = await _supabase
          .from('itinerary_nodes')
          .select()
          .eq('quotation_id', quotationId);

      print('🔍 [DB_READ] Returned ${(res as List).length} itinerary nodes from database.');
      final nodes = (res as List)
          .map((r) => ItineraryNodeModel.fromJson(r as Map<String, dynamic>))
          .toList();
      nodes.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (int i = 0; i < nodes.length; i++) {
        print('   🔹 Node $i: ID="${nodes[i].id}" [${nodes[i].nodeType}] "${nodes[i].title}" (isDraggable: ${nodes[i].isDraggable}, order: ${nodes[i].orderIndex}, price: ₹${nodes[i].finalPrice})');
      }
      return nodes;
    } catch (e, stack) {
      print('❌ [DB_READ] Error fetching itinerary_nodes for quotation "$quotationId": $e\n$stack');
      return [];
    }
  }

  // ── 7. Update Node Coordinates / Order in Database (Drag & Drop) ───────────
  Future<bool> updateNodeCoordinates({
    required String nodeId,
    required Map<String, dynamic> coordinates,
  }) async {
    try {
      print('🚀 [DB_UPDATE] Overwriting ui_coordinates for node "$nodeId" -> $coordinates');
      final res = await _supabase.from('itinerary_nodes').update({
        'ui_coordinates': coordinates,
      }).eq('id', nodeId).select();

      print('✅ [DB_UPDATE] Node coordinates updated successfully in database: $res');
      return true;
    } catch (e, stack) {
      print('❌ [DB_UPDATE] Error updating node "$nodeId" coordinates in database: $e\n$stack');
      return false;
    }
  }

  // ── 8. Batch Update Node Sequence in Database ─────────────────────────────
  Future<bool> batchUpdateNodeOrder(List<ItineraryNodeModel> nodes) async {
    try {
      print('🚀 [DB_UPDATE] Batch updating sequence for ${nodes.length} nodes in database...');
      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final currentCoords = Map<String, dynamic>.from(node.uiCoordinates);
        currentCoords['order'] = i;
        currentCoords['day'] = node.dayNumber;
        currentCoords['y'] = i * 120;

        print('   🔄 Updating Node $i: ID="${node.id}" title="${node.title}" -> order: $i');
        await updateNodeCoordinates(nodeId: node.id, coordinates: currentCoords);
      }
      print('✅ [DB_UPDATE] All ${nodes.length} nodes successfully updated in database!');
      return true;
    } catch (e, stack) {
      print('❌ [DB_UPDATE] Error during batch update of nodes: $e\n$stack');
      return false;
    }
  }

  // ── 9. Submit Counter-Offer to Database (Phase 4) ───────────────────────────
  Future<bool> submitCounterOffer({
    required String quotationId,
    required double newTotalPrice,
    required double perPersonPrice,
    String? customerNotes,
  }) async {
    try {
      print('🚀 [DB_UPDATE] Submitting counter-offer to quotations table:');
      print('   - Quotation ID: "$quotationId"');
      print('   - New Total Price: ₹$newTotalPrice');
      print('   - Customer Notes: "$customerNotes"');

      // Note: per_person_price is GENERATED ALWAYS STORED in PostgreSQL, so we do NOT send it
      final updatePayload = <String, dynamic>{
        'status': 'user_countered',
        'total_final_price': newTotalPrice,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('🔍 [DB_UPDATE] Executing quotations update payload: $updatePayload');
      final res = await _supabase
          .from('quotations')
          .update(updatePayload)
          .eq('id', quotationId)
          .select();

      print('✅ [DB_UPDATE] Counter-offer successfully updated in database: $res');
      return true;
    } catch (e, stack) {
      print('❌ [DB_UPDATE] Error updating quotations table with counter-offer: $e\n$stack');
      return false;
    }
  }

  // ── 10. Accept Quotation in Database ───────────────────────────────────────
  Future<bool> acceptQuotation(String quotationId) async {
    try {
      print('🎉 [DB_UPDATE] Updating quotation ID "$quotationId" status to "accepted" in database');
      final res = await _supabase.from('quotations').update({
        'status': 'accepted',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', quotationId).select();

      print('✅ [DB_UPDATE] Quotation status accepted in database: $res');
      return true;
    } catch (e, stack) {
      print('❌ [DB_UPDATE] Error accepting quotation in database: $e\n$stack');
      return false;
    }
  }

  // ── 11. Fetch Received Quotations for Logged-In User ─────────────────────
  Future<List<Map<String, dynamic>>> getUserReceivedQuotations() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      print('🔍 [DB_READ] Fetching received quotations for user: $currentUserId');

      List<dynamic> tripReqRows = [];
      if (currentUserId != null) {
        tripReqRows = await _supabase
            .from('trip_requests')
            .select('id, destination, trip_mode, assigned_group_name, start_date, end_date, per_person_budget')
            .eq('customer_id', currentUserId);
      }

      final tripReqMap = <String, Map<String, dynamic>>{};
      for (final r in (tripReqRows as List)) {
        tripReqMap[r['id'].toString()] = Map<String, dynamic>.from(r as Map);
      }
      final tripReqIds = tripReqMap.keys.toList();

      List<dynamic> quotesRows = [];
      if (tripReqIds.isNotEmpty) {
        print('🔍 [DB_READ] Finding quotations for trip_request_ids: $tripReqIds');
        quotesRows = await _supabase
            .from('quotations')
            .select()
            .inFilter('trip_request_id', tripReqIds)
            .order('created_at', ascending: false);
      } else {
        print('⚠️ [DB_READ] No trip requests for user ID, checking recent quotations table');
        quotesRows = await _supabase
            .from('quotations')
            .select()
            .order('created_at', ascending: false)
            .limit(10);
      }

      print('✅ [DB_READ] Total quotations fetched: ${quotesRows.length}');
      return (quotesRows as List).map((q) {
        final quoteMap = Map<String, dynamic>.from(q as Map);
        final tripId = quoteMap['trip_request_id']?.toString() ?? '';
        final tripInfo = tripReqMap[tripId] ?? {};
        return {
          'quotation': QuotationModel.fromJson(quoteMap),
          'trip_request': tripInfo,
        };
      }).toList();
    } catch (e, stack) {
      print('❌ [DB_READ] Error fetching received quotations: $e\n$stack');
      return [];
    }
  }

  // ── 12. Fetch Single Node Details from Database using Quotation ID ────────
  Future<ItineraryNodeModel?> getNodeDetail({
    required String quotationId,
    required String nodeId,
  }) async {
    try {
      print('🔍 [DB_READ] Searching itinerary_nodes where quotation_id == "$quotationId" AND id == "$nodeId"');
      final res = await _supabase
          .from('itinerary_nodes')
          .select()
          .eq('quotation_id', quotationId)
          .eq('id', nodeId)
          .maybeSingle();

      print('🔍 [DB_READ] Node detail database response: $res');
      if (res != null) {
        final node = ItineraryNodeModel.fromJson(Map<String, dynamic>.from(res));
        print('✅ [DB_READ] Fetched node detail: "${node.title}" (${node.nodeType}) finalPrice: ₹${node.finalPrice}');
        return node;
      }
      return null;
    } catch (e, stack) {
      print('❌ [DB_READ] Error searching itinerary_nodes for quotation_id "$quotationId": $e\n$stack');
      return null;
    }
  }
}

