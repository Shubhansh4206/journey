import 'package:flutter_test/flutter_test.dart';
import 'package:guide_app/models/guide_models.dart';
import 'package:guide_app/models/quotation_item_model.dart';
import 'package:guide_app/services/guide_quotation_service.dart';
import 'package:guide_app/state/guide_state.dart';

void main() {
  group('SupabaseQuotation Model Tests', () {
    test('Correctly parses quotation from Supabase JSON with generated column', () {
      final json = {
        'id': '1a548919-f713-4138-9b74-db4c573a1dd2',
        'trip_request_id': '46c07971-e99b-409f-891d-3bbe9ee8805a',
        'operator_id': '4401ba03-68d7-463d-83cb-1e1ca8cb0760',
        'title': 'Mumbai Heritage & Sightseeing Tour',
        'status': 'finalized',
        'total_base_cost': 240.00,
        'total_final_price': 276.00,
        'valid_until': '2026-10-01T12:00:00Z',
        'created_at': '2026-09-27T06:00:00Z',
        'updated_at': '2026-09-27T06:10:00Z',
        'pax_count': 2,
        'per_person_price': 138.00,
      };

      final quote = SupabaseQuotation.fromJson(json);

      expect(quote.id, '1a548919-f713-4138-9b74-db4c573a1dd2');
      expect(quote.tripRequestId, '46c07971-e99b-409f-891d-3bbe9ee8805a');
      expect(quote.operatorId, '4401ba03-68d7-463d-83cb-1e1ca8cb0760');
      expect(quote.title, 'Mumbai Heritage & Sightseeing Tour');
      expect(quote.status, 'finalized');
      expect(quote.isFinalized, isTrue);
      expect(quote.totalFinalPrice, 276.00);
      expect(quote.paxCount, 2);
      expect(quote.perPersonPrice, 138.00);
    });

    test('Omits generated per_person_price when serializing for Supabase write', () {
      final quote = SupabaseQuotation(
        id: 'test-id',
        tripRequestId: 'trip-id',
        operatorId: 'operator-id',
        title: 'Custom Tour',
        status: 'finalized',
        totalBaseCost: 100.0,
        totalFinalPrice: 120.0,
        paxCount: 2,
        perPersonPrice: 60.0,
      );

      final updatePayload = quote.toJson();
      expect(updatePayload.containsKey('per_person_price'), isFalse);
      expect(updatePayload['status'], 'finalized');
      expect(updatePayload['total_final_price'], 120.0);
    });

    test('Recognizes British spelling finalised as finalized', () {
      final quote = SupabaseQuotation(
        id: 'test-id-2',
        tripRequestId: 'trip-id-2',
        operatorId: 'operator-id-2',
        title: 'Goa Coastal Adventure',
        status: 'finalised',
        totalBaseCost: 500.0,
        totalFinalPrice: 550.0,
      );

      expect(quote.isFinalized, isTrue);
    });
  });

  group('ItineraryLocationItem & Coordinate Tests', () {
    test('Formats coordinates with N/S and E/W correctly', () {
      final item = ItineraryLocationItem(
        id: 'place-1',
        title: 'Gateway of India',
        category: 'place',
        latitude: 18.9220,
        longitude: 72.8347,
        subtitle: 'Colaba, Mumbai',
        price: 0.0,
        dayNumber: 1,
      );

      expect(item.formattedCoordinates, '18.9220° N, 72.8347° E');
    });

    test('Fallback registry provides coordinates for key landmarks', () {
      final gatewayCoords = GuideQuotationService.resolveCoordinatesStatic(
        name: 'Gateway of India',
        city: 'Mumbai',
      );
      expect(gatewayCoords['lat'], closeTo(18.922, 0.01));
      expect(gatewayCoords['lng'], closeTo(72.834, 0.01));

      final hotelCoords = GuideQuotationService.resolveCoordinatesStatic(
        name: 'The Taj Mahal Palace',
        city: 'Mumbai',
      );
      expect(hotelCoords['lat'], closeTo(18.9217, 0.01));
      expect(hotelCoords['lng'], closeTo(72.8333, 0.01));
    });
  });

  group('SOS Safety & Tour Operator Contact Tests', () {
    test('TourOperatorContact defaults to Journey Central Operations Desk', () {
      const contact = TourOperatorContact();
      expect(contact.name, contains('Journey'));
      expect(contact.hotlinePhone, contains('1800'));
      expect(contact.secondaryPhone, isNotEmpty);
      expect(contact.email, 'emergency-ops@journeyguide.com');
      expect(contact.dutyDesk, contains('24/7'));
    });

    test('SosEmergencyAlert creates valid active alert and handles resolution', () {
      final alert = SosEmergencyAlert(
        id: 'sos-12345',
        packageId: 'pkg-1',
        tourTitle: 'South Bombay Art Deco Walk',
        destination: 'Mumbai, Maharashtra',
        guideId: 'guide-01',
        guideName: 'Aarav Mehta',
        guidePhone: '+91 98201 12345',
        emergencyType: 'Medical Emergency',
        notes: 'Tourist felt dizzy near Oval Maidan',
        latitude: 18.9298,
        longitude: 72.8296,
        locationName: 'Oval Maidan',
        operatorContact: const TourOperatorContact(),
        timestamp: DateTime.now(),
        isResolved: false,
      );

      expect(alert.isResolved, isFalse);
      expect(alert.emergencyType, 'Medical Emergency');
      expect(alert.latitude, 18.9298);

      alert.isResolved = true;
      alert.resolvedAt = DateTime.now();
      alert.resolutionNotes = 'First aid applied. Tourist recovering safely.';

      expect(alert.isResolved, isTrue);
      expect(alert.resolutionNotes, contains('First aid'));
    });
  });

  group('GuideState Tour Lifecycle & SOS Workflow Tests', () {
    test('Starts tour and sets ongoing status', () {
      final state = GuideState();
      final pkg = state.acceptedPackages.first;
      expect(pkg.isAcceptedOrOngoing, isTrue);

      state.startTour(pkg.id);
      expect(state.ongoingTour?.id, pkg.id);
      expect(state.ongoingTour?.isOngoing, isTrue);
      expect(state.ongoingTour?.isAcceptedOrOngoing, isTrue);

      state.completeTour(pkg.id);
      expect(state.ongoingTour, isNull);
    });

    test('Triggers SOS alert, broadcasts message to chat, and resolves alert', () async {
      final state = GuideState();
      final pkg = state.acceptedPackages.first;
      state.startTour(pkg.id);

      expect(state.isSosActive(pkg.id), isFalse);

      final alert = await state.triggerSosAlert(
        package: pkg,
        emergencyType: 'Medical Emergency',
        notes: 'Needs paramedic attention',
      );

      expect(state.isSosActive(pkg.id), isTrue);
      expect(state.activeSosAlert?.id, alert.id);
      expect(alert.emergencyType, 'Medical Emergency');

      // Verify chat broadcast
      final messages = state.getMessagesForPackage(pkg.id);
      final sosMsg = messages.firstWhere((m) => m.isSosAlert);
      expect(sosMsg.isSosAlert, isTrue);
      expect(sosMsg.message, contains('EMERGENCY PROTOCOL ACTIVATED'));
      expect(sosMsg.message, contains('Tour Operator Operations Desk'));

      // Resolve SOS alert
      state.resolveSosAlert(
        alert.id,
        notes: 'Ambulance attended. Guide and tourists safe.',
      );

      expect(state.isSosActive(pkg.id), isFalse);
      expect(state.activeSosAlert, isNull);

      final updatedMessages = state.getMessagesForPackage(pkg.id);
      final standDownMsg = updatedMessages.last;
      expect(standDownMsg.message, contains('ALL CLEAR - SOS RESOLVED'));
    });

    test('getItineraryLocationsForPackage resolves OSM coordinates for packages', () async {
      final state = GuideState();
      final pkg = state.allPackages.first; // pkg_goa_01 Fontainhas, Goa

      final stops = await state.getItineraryLocationsForPackage(pkg);
      expect(stops.isNotEmpty, isTrue);
      expect(stops.first.latitude, isNotNull);
      expect(stops.first.longitude, isNotNull);
      expect(stops.first.latitude, closeTo(15.49, 0.05));
      expect(stops.first.longitude, closeTo(73.83, 0.05));
    });
  });
}
