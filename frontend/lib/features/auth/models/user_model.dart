class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.token,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isReceptionist => role.toLowerCase() == 'receptionist';
  bool get isStaff => isAdmin || isReceptionist || role.toLowerCase() == 'housekeeping';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role']?.toString() ?? 'Guest',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'token': token,
    };
  }
}
