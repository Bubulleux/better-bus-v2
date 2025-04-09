import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/animation.dart';
// TODO: Remove this file
class ConnectivityStatus {
  final Connectivity connectivity = Connectivity();
  List<ConnectivityResult>? _connection;

  bool? get connected => disconnected == false;
  bool? get disconnected => _connection?.contains(ConnectivityResult.none);

  ConnectivityStatus({bool autoUpdate = true}) {
    if (autoUpdate) {
      connectivity.onConnectivityChanged.listen((data) {
        _connection = data;
      });
    }
  }


  Future<bool> isConnected() async {
    _connection = await connectivity.checkConnectivity();

    return connected ?? false;
  }

  Future<bool> isWifiConnected() async {
    _connection = await connectivity.checkConnectivity();

    return _connection?.contains(ConnectivityResult.wifi) ?? false;
  }
}
