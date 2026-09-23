import 'package:flutter_test/flutter_test.dart';
import 'package:app_full/core/error/exceptions.dart';
import 'package:app_full/core/error/failures.dart';
import 'package:app_full/core/network/network_info.dart';
import 'package:app_full/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_full/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_full/features/auth/data/models/user_model.dart';
import 'package:app_full/features/auth/data/repositories/auth_repository_impl.dart';

/// --- Fakes à la main : pas besoin de build_runner/mockito, suffisant
/// pour tester la logique d'orchestration du repository en isolation. ---

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldThrowAuthException = false;
  final tUser = const UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  @override
  Future<UserModel> login({required String username, required String password}) async {
    if (shouldThrowAuthException) throw AuthException('Identifiants invalides.');
    return tUser;
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async =>
      tUser;
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserModel? cached;

  @override
  Future<void> cacheUser(UserModel user) async => cached = user;

  @override
  Future<UserModel?> getCachedUser() async => cached;

  @override
  Future<void> clearUser() async => cached = null;
}

class FakeNetworkInfo implements NetworkInfo {
  bool connected = true;
  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  late FakeAuthRemoteDataSource remote;
  late FakeAuthLocalDataSource local;
  late FakeNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = FakeAuthRemoteDataSource();
    local = FakeAuthLocalDataSource();
    networkInfo = FakeNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );
  });

  group('login', () {
    test('retourne un UserEntity et met en cache quand le réseau est dispo', () async {
      networkInfo.connected = true;

      final result = await repository.login(username: 'emilys', password: 'emilyspass');

      expect(result.isRight(), true);
      result.match(
        (l) => fail('ne devrait pas échouer'),
        (user) => expect(user.username, 'emilys'),
      );
      expect(local.cached, isNotNull); // vérifie que le cache a bien été rempli
    });

    test('retourne NetworkFailure sans appeler le remote si hors-ligne', () async {
      networkInfo.connected = false;

      final result = await repository.login(username: 'emilys', password: 'emilyspass');

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (r) => fail('ne devrait pas réussir'),
      );
    });

    test('retourne AuthFailure quand les identifiants sont invalides', () async {
      networkInfo.connected = true;
      remote.shouldThrowAuthException = true;

      final result = await repository.login(username: 'wrong', password: 'wrong');

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<AuthFailure>()),
        (r) => fail('ne devrait pas réussir'),
      );
    });
  });

  group('logout', () {
    test('vide le cache utilisateur', () async {
      local.cached = remote.tUser;

      final result = await repository.logout();

      expect(result.isRight(), true);
      expect(local.cached, isNull);
    });
  });
}
