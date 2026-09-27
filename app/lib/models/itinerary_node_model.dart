class ItineraryNodeModel {
  final String id;
  final String quotationId;
  final String nodeType; // 'ACTIVITY', 'TRANSFER', 'HOTEL', 'FLIGHT', 'PLACE'
  final String title;
  final String? locationSubtitle;
  final int dayNumber;
  final String? timeSlot;
  final double baseCost;
  final double marginPercentage;
  final double finalPrice;
  final Map<String, dynamic> uiCoordinates; // JSONB: e.g. {'order': 1, 'day': 1, 'time': '10:00 AM', 'x': 100, 'y': 100}
  final String? originalInventoryId;
  final DateTime? createdAt;

  ItineraryNodeModel({
    required this.id,
    required this.quotationId,
    required this.nodeType,
    required this.title,
    this.locationSubtitle,
    this.dayNumber = 1,
    this.timeSlot,
    this.baseCost = 0.0,
    this.marginPercentage = 0.0,
    this.finalPrice = 0.0,
    this.uiCoordinates = const {'order': 0, 'day': 1, 'x': 100, 'y': 100},
    this.originalInventoryId,
    this.createdAt,
  });

  /// Check if the node can be dragged and reordered by the customer.
  /// Rule: 'ACTIVITY', 'TRANSFER', 'PLACE' are draggable.
  /// 'HOTEL' and 'FLIGHT' are locked fixed anchors.
  bool get isDraggable {
    final type = nodeType.toUpperCase();
    return type == 'ACTIVITY' ||
        type == 'TRANSFER' ||
        type == 'TRANSPORT' ||
        type == 'PLACE';
  }

  bool get isFixedCore {
    final type = nodeType.toUpperCase();
    return type == 'HOTEL' || type == 'FLIGHT';
  }

  int get orderIndex {
    if (uiCoordinates.containsKey('order')) {
      final val = uiCoordinates['order'];
      if (val is int) return val;
      if (val is num) return val.toInt();
    }
    if (uiCoordinates.containsKey('y')) {
      final val = uiCoordinates['y'];
      if (val is num) return (val / 100).round();
    }
    return dayNumber * 10;
  }

  factory ItineraryNodeModel.fromJson(Map<String, dynamic> json) {
    final coords = json['ui_coordinates'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['ui_coordinates'])
        : <String, dynamic>{'order': 0, 'day': 1, 'x': 100, 'y': 100};

    final day = (coords['day'] as num?)?.toInt() ??
        (json['day_number'] as num?)?.toInt() ??
        1;
    final time = coords['time']?.toString() ?? json['time_slot']?.toString();

    final baseCost = (json['base_cost'] as num?)?.toDouble() ?? 0.0;
    final margin = (json['margin_percentage'] as num?)?.toDouble() ?? 0.0;
    final finalPrice = (json['final_price'] as num?)?.toDouble() ??
        (baseCost + (baseCost * margin / 100));

    return ItineraryNodeModel(
      id: json['id']?.toString() ?? '',
      quotationId: json['quotation_id']?.toString() ?? '',
      nodeType: (json['node_type'] ?? 'ACTIVITY').toString().toUpperCase(),
      title: json['title']?.toString() ?? 'Activity',
      locationSubtitle: json['location_subtitle']?.toString(),
      dayNumber: day,
      timeSlot: time,
      baseCost: baseCost,
      marginPercentage: margin,
      finalPrice: finalPrice,
      uiCoordinates: coords,
      originalInventoryId: json['original_inventory_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'node_type': nodeType,
      'title': title,
      'location_subtitle': locationSubtitle,
      'base_cost': baseCost,
      'margin_percentage': marginPercentage,
      'ui_coordinates': uiCoordinates,
      'original_inventory_id': originalInventoryId,
    };
  }

  ItineraryNodeModel copyWith({
    String? id,
    String? quotationId,
    String? nodeType,
    String? title,
    String? locationSubtitle,
    int? dayNumber,
    String? timeSlot,
    double? baseCost,
    double? marginPercentage,
    double? finalPrice,
    Map<String, dynamic>? uiCoordinates,
    String? originalInventoryId,
    DateTime? createdAt,
  }) {
    return ItineraryNodeModel(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      nodeType: nodeType ?? this.nodeType,
      title: title ?? this.title,
      locationSubtitle: locationSubtitle ?? this.locationSubtitle,
      dayNumber: dayNumber ?? this.dayNumber,
      timeSlot: timeSlot ?? this.timeSlot,
      baseCost: baseCost ?? this.baseCost,
      marginPercentage: marginPercentage ?? this.marginPercentage,
      finalPrice: finalPrice ?? this.finalPrice,
      uiCoordinates: uiCoordinates ?? this.uiCoordinates,
      originalInventoryId: originalInventoryId ?? this.originalInventoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
