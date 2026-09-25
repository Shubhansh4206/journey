class OperatorProfile {
  final String id;
  final String companyName;
  final String contactEmail;
  final bool verifiedBadge;
  final DateTime? createdAt;

  OperatorProfile({
    required this.id,
    required this.companyName,
    required this.contactEmail,
    this.verifiedBadge = false,
    this.createdAt,
  });

  factory OperatorProfile.fromJson(Map<String, dynamic> json) {
    return OperatorProfile(
      id: json['id'] as String,
      companyName: json['company_name'] as String,
      contactEmail: json['contact_email'] as String,
      verifiedBadge: json['verified_badge'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'contact_email': contactEmail,
      'verified_badge': verifiedBadge,
    };
  }
}

class OperatorInventory {
  final String id;
  final String operatorId;
  final String inventoryType; // 'hotel', 'transport', 'activity'
  final String name;
  final double internalCost;
  final double? geoLat;
  final double? geoLng;
  final DateTime? createdAt;

  OperatorInventory({
    required this.id,
    required this.operatorId,
    required this.inventoryType,
    required this.name,
    required this.internalCost,
    this.geoLat,
    this.geoLng,
    this.createdAt,
  });

  factory OperatorInventory.fromJson(Map<String, dynamic> json) {
    return OperatorInventory(
      id: json['id'] as String,
      operatorId: json['operator_id'] as String,
      inventoryType: json['inventory_type'] as String,
      name: json['name'] as String,
      internalCost: (json['internal_cost'] as num).toDouble(),
      geoLat: (json['geo_lat'] as num?)?.toDouble(),
      geoLng: (json['geo_lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operator_id': operatorId,
      'inventory_type': inventoryType,
      'name': name,
      'internal_cost': internalCost,
      'geo_lat': geoLat,
      'geo_lng': geoLng,
    };
  }
}