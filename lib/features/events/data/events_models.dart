class Event {
  final int id;
  final String title;
  final String description;
  final String startDatetime;
  final String endDatetime;
  final String? location;
  final String? category;
  final String? poster;
  final int rsvpCount;
  final bool isRsvped;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    this.location,
    this.category,
    this.poster,
    required this.rsvpCount,
    required this.isRsvped,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      startDatetime: json['start_datetime'],
      endDatetime: json['end_datetime'],
      location: json['location'],
      category: json['category'],
      poster: json['poster'],
      rsvpCount: json['rsvp_count'] ?? 0,
      isRsvped: json['is_rsvped'] ?? false,
    );
  }

  DateTime get startDate => DateTime.parse(startDatetime);
  DateTime get endDate => DateTime.parse(endDatetime);

  bool get isToday {
    final now = DateTime.now();
    return startDate.day == now.day &&
        startDate.month == now.month &&
        startDate.year == now.year;
  }

  bool get isUpcoming => startDate.isAfter(DateTime.now());
}
