import 'package:better_bus_v2/data_provider/cache_data_provider.dart';
import 'vitalis_data_provider.dart';
const String version  = "0.1";
const String versionURL = "https://pastebin.com/raw/0uFw7Vze";
const CacheDataProvider cache = CacheDataProvider(key: "version", expiration: Duration(days: 1));

class VersionDataProvider {
  static Future<String?> checkIfNewVersion() async {
    Map<String, dynamic> data = await VitalisDataProvider.sendRequest(Uri.parse(versionURL), cache: cache);
    if (data["version"] != version) {
      return data["download-link"] as String;
    }
    return null;
  }
}