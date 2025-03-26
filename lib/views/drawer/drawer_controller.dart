import 'package:better_bus_v2/views/drawer/drawer.dart';

class MapDrawerController {
  MapDrawerState? state;

  void setState(MapDrawerState state) {
    this.state = state;
  }

  void lowerDrawer() {
    assert(state != null);
    if (state!.mounted) {
      print("Height set");
      state!.setDrawerHeight(200);
    }
  }
}