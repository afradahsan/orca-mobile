import 'dart:convert';
enum UserRole { owner, member, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool active;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.member,
    this.active = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? "",
      name: json['name'] ?? "Unnamed User",
      email: json['email'] ?? "No Email",
      role: UserRole.values.firstWhere(
        (r) => r.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.member,
      ),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.toString().split('.').last,
        'active': active,
      };
}

extension UserModelHelpers on UserModel {
  String toJsonString() => jsonEncode(toJson());
}

extension UserModelFromJsonString on UserModel {
  static UserModel fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}