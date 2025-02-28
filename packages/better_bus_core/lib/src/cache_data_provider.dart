import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String cacheDateFile = "date-cache";

class CacheDataProvider {
  const CacheDataProvider({required this.key, required this.expiration});

  final String key;
  final Duration expiration;

  Future<String?> getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, DateTime> cacheData = await getCachesDates();
    if (!cacheData.containsKey(key) || DateTime.now().difference(cacheData[key]!) > expiration){
      return null;
    }
    return preferences.getString("cache-$key");
  }

  Future setData(String data) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("cache-$key", data);
    await setCacheDate(key);
  }

  static Future<Map<String, DateTime>> getCachesDates() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String rawData = preferences.getString(cacheDateFile) ?? "{}";
    Map<String, dynamic> parseData = jsonDecode(rawData);
    return parseData.map((key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value)));
  }

  static Future setCacheDate(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map<String, DateTime> cacheDataDate = await getCachesDates();
    cacheDataDate[key] = DateTime.now();
    String rawData = jsonEncode(cacheDataDate.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)));
    await preferences.setString(cacheDateFile, rawData);
  }

  static Future emptyCacheData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(cacheDateFile);
    Set<String> keys = preferences.getKeys();
    for (String key in keys) {
      if (key.startsWith("cache-")){
        await preferences.remove(key);
      }
    }
  }
}