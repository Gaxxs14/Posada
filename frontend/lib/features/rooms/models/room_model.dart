class RoomModel {
  final String id;
  final String roomNumber;
  final String title;
  final String description;
  final String type;
  final double pricePerNightUsd;
  final int capacity;
  final List<String> amenities;
  final List<String> imageUrls;
  final String status;
  final int floor;
  final bool isActive;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.pricePerNightUsd,
    required this.capacity,
    required this.amenities,
    required this.imageUrls,
    required this.status,
    required this.floor,
    required this.isActive,
  });

  bool get isAvailable => status.toLowerCase() == 'available';

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type']?.toString() ?? 'Double',
      pricePerNightUsd: (json['pricePerNightUsd'] as num?)?.toDouble() ?? 0.0,
      capacity: json['capacity'] ?? 2,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status']?.toString() ?? 'Available',
      floor: json['floor'] ?? 1,
      isActive: json['isActive'] ?? true,
    );
  }
}
