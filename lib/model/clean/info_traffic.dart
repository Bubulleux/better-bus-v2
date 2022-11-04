class InfoTraffic {
  InfoTraffic({
    required this.id,
    required this.title,
    required this.content,
    required this.link,
    required this.startTime,
    required this.stopTime,
    required this.startDisplay,
    required this.stopDisplay,
    required this.linesId,
    required this.isActive,
    required this.isDisplay,
  });

  InfoTraffic.fromJson(Map<String, dynamic> json): this(
    id: json["info_id"],
    title: json["title"],
    content: json["content"],
    link: json["link"] == "" ? null : json["link"],
    startTime: DateTime.fromMillisecondsSinceEpoch(json["starting_at"] * 1000),
    stopDisplay: DateTime.fromMillisecondsSinceEpoch(json["ending_at"] * 1000),
    startDisplay: DateTime.fromMillisecondsSinceEpoch(json["display_start"] * 1000),
    stopTime: DateTime.fromMillisecondsSinceEpoch(json["display_end"] * 1000),
    linesId: json["lines"]?.map((e) => e["slug"]).toList().cast<String>(),
    isActive: json["isActive"],
    isDisplay: json["isDisplayable"],
  );

  final int id;
  final String title;
  final String content;
  final String? link;

  final DateTime startTime;
  final DateTime stopTime;

  final DateTime startDisplay;
  final DateTime stopDisplay;

  final List<String>? linesId;

  final bool isDisplay;
  final bool isActive;

}