import 'package:url_launcher/url_launcher.dart';

class MapsRouter{
  static routeToMap(double latitude, double longitude) {
    Uri uri = Uri.parse("https://www.google.fr/maps/place/$latitude,$longitude/");
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}