import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const boxName = 'auth_box';
  static const userKey = 'current_user';

  final TokenStorage tokenStorage;
  AuthLocalDataSourceImpl({required this.tokenStorage});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.put(userKey, user.toJson());
    } catch (_) {
      throw CacheException("Impossible d'enregistrer l'utilisateur en cache.");
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final box = await Hive.openBox(boxName);
      final json = box.get(userKey);
      if (json == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      throw CacheException("Impossible de lire l'utilisateur en cache.");
    }
  }

  @override
  Future<void> clearUser() async {
    final box = await Hive.openBox(boxName);
    await box.delete(userKey);
    await tokenStorage.clear();
  }
}
