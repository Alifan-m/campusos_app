class UserModel {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String? studentId;
  final String? course;
  final int? yearOfStudy;
  final String role;
  final bool isVerified;
  final String? profilePicture;
  final String? dateJoined;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    this.studentId,
    this.course,
    this.yearOfStudy,
    required this.role,
    required this.isVerified,
    this.profilePicture,
    this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? '',
      studentId: json['student_id'],
      course: json['course'],
      yearOfStudy: json['year_of_study'],
      role: json['role'] ?? 'student',
      isVerified: json['is_verified'] ?? false,
      profilePicture: json['profile_picture'],
      dateJoined: json['date_joined'],
    );
  }
}

class AuthTokens {
  final String access;
  final String refresh;

  AuthTokens({required this.access, required this.refresh});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      access: json['access'],
      refresh: json['refresh'],
    );
  }
}
