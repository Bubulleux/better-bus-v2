import 'package:flutter/services.dart';

class CustomHomeWidgetRequest {
  static const methodeChannel = MethodChannel("better.bus.poitier/homeWidget");
  static Future<void> updateWidget() async {
    dynamic result = await methodeChannel.invokeMethod("updateWidget");
    print("Result: ------------------------------");
    print(result);
  }
}