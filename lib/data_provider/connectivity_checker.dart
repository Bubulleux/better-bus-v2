import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/animation.dart';
import 'dart:io';

class ConnectivityStatus {
  final Connectivity connectivity = Connectivity();
  List<ConnectivityResult>? _connection;

  bool? get connected => disconnected == false;
  bool? get disconnected => (Platform.isLinux ? false : 
		_connection?.contains(ConnectivityResult.none));

  Set<VoidCallback> _onConnect = {};

  ConnectivityStatus({bool autoUpdate = true}) {
    if (!Platform.isLinux  && autoUpdate) {
      connectivity.onConnectivityChanged.listen((data) {
        _connection = data;
        if (connected ?? false) {
          _onConnect.forEach((e) => e());
          _onConnect = {};
        }
      });
    }
  }


  Future<bool> isConnected() async {
		if (Platform.isLinux) {
			return Future.value(true);
		}

    _connection = await connectivity.checkConnectivity();

    return connected ?? false;
  }

  Future<bool> isWifiConnected() async {
		if (Platform.isLinux) {
			return Future.value(true);
		}
    _connection = await connectivity.checkConnectivity();

    return _connection?.contains(ConnectivityResult.wifi) ?? false;
  }

  void onConnected(VoidCallback onConnect) {
    _onConnect.add(onConnect);
  }
}
