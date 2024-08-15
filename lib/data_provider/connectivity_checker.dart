import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  static final Connectivity connectivity = Connectivity();

  static Future<bool> isConnected() async {
    List<ConnectivityResult> result = await connectivity.checkConnectivity();

    return !result.contains(ConnectivityResult.none);
  }

    static Future<bool> isWifiConnected() async {
      List<ConnectivityResult> result = await connectivity.checkConnectivity();

      return result.contains(ConnectivityResult.wifi);
    }
}
