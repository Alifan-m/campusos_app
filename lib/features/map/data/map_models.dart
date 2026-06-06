class MapLocation {
  final int id;
  final String name;
  final String locationType;
  final String? description;
  final double locationX;
  final double locationY;

  MapLocation({
    required this.id,
    required this.name,
    required this.locationType,
    this.description,
    required this.locationX,
    required this.locationY,
  });

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    return MapLocation(
      id: json['id'],
      name: json['name'],
      locationType: json['location_type'] ?? 'other',
      description: json['description'],
      locationX: double.parse(json['location_x'].toString()),
      locationY: double.parse(json['location_y'].toString()),
    );
  }
}
