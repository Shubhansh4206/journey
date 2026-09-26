class GuideUser {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String phone;
  final String badge;
  final double rating;
  final int totalTours;
  final List<String> languages;
  final List<String> specialties;
  bool isAvailable;

  GuideUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.phone,
    required this.badge,
    required this.rating,
    required this.totalTours,
    required this.languages,
    required this.specialties,
    this.isAvailable = true,
  });
}

class TouristUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String country;
  final String emergencyContact;
  final String dietaryOrSpecialNotes;
  final int partySize;
  final bool isLeadBooker;

  TouristUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.country,
    required this.emergencyContact,
    this.dietaryOrSpecialNotes = '',
    this.partySize = 1,
    this.isLeadBooker = false,
  });
}

enum PackageStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
}

class TourPackage {
  final String id;
  final String title;
  final String destination;
  final String imageUrl;
  final String duration;
  final String dates;
  final double payoutAmount;
  final int currentBookings;
  final int maxCapacity;
  final String difficulty;
  final String meetingPoint;
  final String meetingPointEta;
  final String logisticsBadge;
  final String description;
  final List<String> highlights;
  final List<String> inclusions;
  final List<TouristUser> tourists;
  PackageStatus status;
  String? rejectionReason;
  DateTime? acceptedAt;

  TourPackage({
    required this.id,
    required this.title,
    required this.destination,
    required this.imageUrl,
    required this.duration,
    required this.dates,
    required this.payoutAmount,
    required this.currentBookings,
    required this.maxCapacity,
    required this.difficulty,
    required this.meetingPoint,
    this.meetingPointEta = '',
    this.logisticsBadge = 'Walking Tour Only',
    required this.description,
    required this.highlights,
    required this.inclusions,
    required this.tourists,
    this.status = PackageStatus.pending,
    this.rejectionReason,
    this.acceptedAt,
  });
}

class ChatMessage {
  final String id;
  final String packageId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final bool isGuide;
  final String message;
  final DateTime timestamp;
  final bool isAnnouncement;

  ChatMessage({
    required this.id,
    required this.packageId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.isGuide,
    required this.message,
    required this.timestamp,
    this.isAnnouncement = false,
  });
}
