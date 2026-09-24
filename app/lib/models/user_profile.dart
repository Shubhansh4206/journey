class UserProfile {
  final String id;
  final String fullName;
  final int? age;
  final String? gender;
  final String? phoneNumber;
  final String? travelExperience;
  final List<String> environmentPreferences;
  final List<String> accommodationStandard;
  final List<String> dietaryNeeds;
  final bool isSmoker;
  final bool isDrinker;

  UserProfile({
    required this.id,
    required this.fullName,
    this.age,
    this.gender,
    this.phoneNumber,
    this.travelExperience,
    this.environmentPreferences = const [],
    this.accommodationStandard = const [],
    this.dietaryNeeds = const [],
    this.isSmoker = false,
    this.isDrinker = false,
  });

  /// Factory constructor to generate the model from Supabase JSON response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      phoneNumber: json['phone_number'] as String?,
      travelExperience: json['travel_experience'] as String?,
      environmentPreferences:
          List<String>.from(json['environment_preferences'] ?? []),
      accommodationStandard:
          List<String>.from(json['accommodation_standard'] ?? []),
      dietaryNeeds: List<String>.from(json['dietary_needs'] ?? []),
      isSmoker: json['is_smoker'] as bool? ?? false,
      isDrinker: json['is_drinker'] as bool? ?? false,
    );
  }

  /// Converts the model to JSON mapping exactly to the Supabase profiles schema
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'phone_number': phoneNumber,
      'travel_experience': travelExperience,
      'environment_preferences': environmentPreferences,
      'accommodation_standard': accommodationStandard,
      'dietary_needs': dietaryNeeds,
      'is_smoker': isSmoker,
      'is_drinker': isDrinker,
    };
  }

  /// Helper copyWith method
  UserProfile copyWith({
    String? fullName,
    int? age,
    String? gender,
    String? phoneNumber,
    String? travelExperience,
    List<String>? environmentPreferences,
    List<String>? accommodationStandard,
    List<String>? dietaryNeeds,
    bool? isSmoker,
    bool? isDrinker,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      travelExperience: travelExperience ?? this.travelExperience,
      environmentPreferences:
          environmentPreferences ?? this.environmentPreferences,
      accommodationStandard:
          accommodationStandard ?? this.accommodationStandard,
      dietaryNeeds: dietaryNeeds ?? this.dietaryNeeds,
      isSmoker: isSmoker ?? this.isSmoker,
      isDrinker: isDrinker ?? this.isDrinker,
    );
  }

  /// Returns true if essential onboarding profile details have been filled
  bool get isCompleted {
    return fullName.trim().isNotEmpty &&
        (age != null ||
            gender != null ||
            travelExperience != null ||
            environmentPreferences.isNotEmpty);
  }
}
