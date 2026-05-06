enum UserRole { admin, student }

class UserModel {
  final String id;
  final String name;
  final UserRole role;

  UserModel({required this.id, required this.name, required this.role});
}
