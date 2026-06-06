class Notice {
  final int id;
  final String title;
  final String body;
  final String category;
  final bool isUrgent;
  final String createdAt;
  final String? postedBy;

  Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.isUrgent,
    required this.createdAt,
    this.postedBy,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      body: json['body'] ?? '',
      category: json['category'] ?? 'General',
      isUrgent: json['is_urgent'] ?? false,
      createdAt: json['created_at'],
      postedBy: json['posted_by'],
    );
  }

  DateTime get createdDate => DateTime.parse(createdAt);
}
