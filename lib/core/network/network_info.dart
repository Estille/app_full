import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction pour vérifier la connectivité — permet de mocker
/// facilement dans les tests de repository.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
