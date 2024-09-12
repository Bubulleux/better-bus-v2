import 'package:flutter/services.dart';

class CustomHomeWidgetRequest {
  static const methodeChannel = MethodChannel("home_widget");
  static Future<void> updateWidget() async {
    await methodeChannel.invokeMethod("updateWidget");
  }

  static Future<void> setWidgetData(List<String> shortcuts, List<int> shortcutsIds) async {
    String data = shortcuts.join(";");
    await methodeChannel.invokeMethod("setWidgetData", {"data" : data} );
  }
}
