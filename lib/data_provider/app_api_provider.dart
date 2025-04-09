import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';

class AppApiProvider extends ApiProvider {
  final ConnectivityStatus connectivityStatus;
  AppApiProvider(this.connectivityStatus) : super.vitalis();

  @override
  Future<bool> init() async {
    await connectivityStatus.isConnected();
    if (connectivityStatus.disconnected ?? true) {
      return false;
    }

    return await super.init();
  }

  @override
  bool isAvailable() {
    if (connectivityStatus.disconnected == true) return false;
    return super.isAvailable();
  }
}