import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  static final Connectivity connectivity = Connectivity();

  static Future<bool> isConnected() async {
    ConnectivityResult result = await connectivity.checkConnectivity();

    return result != ConnectivityResult.none;
  }
}