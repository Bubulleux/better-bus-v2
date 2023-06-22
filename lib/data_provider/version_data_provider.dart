import 'package:better_bus_v2/data_provider/cache_data_provider.dart';
import 'vitalis_data_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String versionURL = "https://pastebin.com/raw/0uFw7Vze";
const CacheDataProvider cache = CacheDataProvider(key: "version", expiration: Duration(days: 1));

class VersionDataProvider {
  static Future<String?> checkIfNewVersion() async {
    // Disable this function not nedded afet publication on PlayStore
    return null;
    Map<String, dynamic> data = await VitalisDataProvider.sendRequest(Uri.parse(versionURL), cache: cache);
    String version = (await PackageInfo.fromPlatform()).version;
    if (data["version"] != version) {
      return data["download-link"] as String;
    }
    return null;
  }
}
