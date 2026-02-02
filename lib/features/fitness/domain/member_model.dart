import 'package:orca/features/auth/domain/user_model.dart';

class MemberModel {
  final String id;
  final UserModel user;
  final String plan;
  final String status;

  MemberModel({
    required this.id,
    required this.user,
    required this.plan,
    required this.status,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'] ?? "",
      user: UserModel.fromJson(json['userId'] ?? {}),   // << FIX IS HERE
      plan: json['plan'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
