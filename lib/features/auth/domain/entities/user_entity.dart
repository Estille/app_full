import 'package:equatable/equatable.dart';

/// Entité "pure" métier — ne dépend d'aucune lib externe (pas de json, pas de Hive).
/// C'est ce que manipule la couche presentation.
class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
