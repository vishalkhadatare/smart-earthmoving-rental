import 'account_type.dart';

class AppUserModel {
  final String id;
  final String name;
  final String email;
  final AccountType accountType;
  final DateTime createdAt;

  AppUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'accountType': accountType.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
