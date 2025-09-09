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
      id: json['id'],
      name: json['name'],
      email: json['email'],
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
