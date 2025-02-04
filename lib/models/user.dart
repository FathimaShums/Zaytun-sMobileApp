// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String? profilePhotoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
