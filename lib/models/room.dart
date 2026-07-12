class Room {
  const Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.description,
    required this.facilities,
    required this.isAvailable,
    required this.visualVariant,
  });

  final String id;
  final String name;
  final int capacity;
  final String description;
  final List<String> facilities;
  final bool isAvailable;
  final int visualVariant;

  factory Room.fromJson(Map<String, dynamic> json) {
    final facilitiesValue = json['facilities'];
    final facilities = facilitiesValue is List
        ? facilitiesValue.map((item) => item.toString()).toList()
        : <String>[];

    return Room(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Ruang tanpa nama',
      capacity: _toInt(json['capacity']),
      description:
          json['description']?.toString() ??
          'Ruang kerja nyaman untuk belajar, diskusi, dan meeting.',
      facilities: facilities,
      isAvailable: _toBool(json['isAvailable'] ?? json['is_available']),
      visualVariant: _toInt(json['visualVariant'] ?? json['visual_variant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'description': description,
      'facilities': facilities,
      'isAvailable': isAvailable,
      'visualVariant': visualVariant,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }
}
