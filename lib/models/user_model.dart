class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final bool? isActive;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.isActive,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}