import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// `AsyncValue<UserEntity?>` :
/// - loading   -> en cours
/// - null      -> pas connecté
/// - UserEntity-> connecté
/// - error     -> Failure.message (affiché tel quel côté UI)
class AuthController extends AsyncNotifier<UserEntity?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<UserEntity?> build() async {
    // Auto-login au démarrage : lit le cache local, pas d'appel réseau.
    final result = await _repo.getCurrentUser();
    return result.match((failure) => null, (user) => user);
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final result = await _repo.login(username: username, password: password);
    state = result.match(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> register(String username, String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repo.register(
      username: username,
      email: email,
      password: password,
    );
    state = result.match(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);
