import 'package:better_bus_v2/data_provider/cache_data_provider.dart';

const String versionURL = "https://pastebin.com/raw/0uFw7Vze";
const CacheDataProvider cache = CacheDataProvider(key: "version", expiration: Duration(days: 1));

class VersionDataProvider {
  static Future<String?> checkIfNewVersion() async {
    return null;
  }
}
