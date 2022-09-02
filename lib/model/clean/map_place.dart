class MapPlace{
  MapPlace({
    required this.title,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  MapPlace.fromJson(Map<String, dynamic> json): this(
    title: json["title"],
    type: json["resultType"],
    latitude: json["position"]["lat"],
    longitude: json["position"]["lng"],
  );

  final String title;
  final String type;
  final double longitude;
  final double latitude;
}