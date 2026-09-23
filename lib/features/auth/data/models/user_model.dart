import '../../domain/entities/user_entity.dart';

/// Le Model sait parler JSON ; l'Entity ne sait pas.
/// C'est la frontière propre entre "data" et "domain".
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'image': image,
      };

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        id: e.id,
        username: e.username,
        email: e.email,
        firstName: e.firstName,
        lastName: e.lastName,
        image: e.image,
      );
}
