import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/provider.dart';
import 'package:flutter/cupertino.dart';
class AppRadarProvider extends RadarClient {
  AppRadarProvider({required super.provider}) : super(apiUrl: Uri.parse("http://192.168.188.242:8080"));
  
  factory AppRadarProvider.of(BuildContext context) {
    return AppRadarProvider(provider: FullProvider.of(context));
  }
}