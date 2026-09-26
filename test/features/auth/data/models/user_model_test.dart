import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/features/auth/data/models/user_model.dart';
import 'package:app_full/features/auth/domain/entities/user_entity.dart';

void main() {
  final tJson = {
    'id': 1,
    'username': 'emilys',
    'email': 'emily@example.com',
    'firstName': 'Emily',
    'lastName': 'Johnson',
    'image': 'https://example.com/avatar.png',
  };

  test('fromJson construit un UserModel correct', () {
    final model = UserModel.fromJson(tJson);

    expect(model.id, 1);
    expect(model.username, 'emilys');
    expect(model.email, 'emily@example.com');
  });

  test('fromEntity conserve toutes les données de l\'entité', () {
    const entity = UserEntity(
      id: 5,
      username: 'john',
      email: 'john@example.com',
      firstName: 'John',
      lastName: 'Doe',
    );

    final model = UserModel.fromEntity(entity);

    expect(model.id, entity.id);
    expect(model.username, entity.username);
    expect(model.email, entity.email);
  });

  test('toJson puis fromJson redonne un objet équivalent (round-trip)', () {
    final original = UserModel.fromJson(tJson);
    final roundTripped = UserModel.fromJson(original.toJson());

    expect(roundTripped.id, original.id);
    expect(roundTripped.username, original.username);
    expect(roundTripped.image, original.image);
  });
}
