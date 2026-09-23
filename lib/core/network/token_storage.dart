import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralise la lecture/écriture des tokens JWT.
/// Utilise flutter_secure_storage (Keychain/Keystore) plutôt que Hive,
/// car un token ne doit jamais être stocké en clair sur le disque.
class TokenStorage {
  final FlutterSecureStorage _storage;
  TokenStorage(this._storage);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> get hasSession async => (await accessToken) != null;
}
