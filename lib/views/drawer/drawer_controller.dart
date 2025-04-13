import 'package:better_bus_v2/views/drawer/drawer.dart';

class MapDrawerController {
  MapDrawerState? state;

  void setState(MapDrawerState state) {
    this.state = state;
  }

  void lowerDrawer() {
    assert(state != null);
    if (state!.mounted) {
      state!.setDrawerHeight(200);
    }
  }

  void fullyOppen() {
    assert(state != null);
    if (state!.mounted) {
      state!.setDrawerHeight(double.infinity);
    }
  }

  void lockOpen() {
    assert(state != null);
    if (state!.mounted) {
      state!.locked = true;
      state!.setDrawerHeight(double.infinity, animate: false);
    }
  }

  void unLock() {
    assert(state != null);
    if (state!.mounted) {
      state!.locked = false;
    }
  }
}
