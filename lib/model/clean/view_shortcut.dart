import 'bus_stop.dart';
import 'terminal.dart';

class ViewShortcut {
  ViewShortcut(this.shortcutName, this.stop, this.terminals);

  ViewShortcut.example() : this("View Shortcut Name", BusStop.example(), [Terminal.example(), Terminal.example(), Terminal.example()]);

  String shortcutName;
  BusStop stop;
  List<Terminal> terminals;
}