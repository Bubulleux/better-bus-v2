import 'dart:convert';

import 'package:better_bus_core/core.dart';
import 'package:http/http.dart' as http;

class VitalisDownloader extends GTFSDataDownloader {
  VitalisDownloader({required super.paths});


  @override
  Future<DatasetMetadata> getFileMetaData() async {
    final uri = Uri.parse("https://data.grandpoitiers.fr/data-fair/api/v1/datasets/offre-de-transport-du-reseau-vitalis");
    http.Response res = await http.get(uri);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    var ressource =
    json["attachments"].firstWhere((e) => e["title"] == "gtfs.zip");

    final dataUri = Uri.parse(ressource["url"]);
    DateTime updateTime = DateTime.parse(ressource["updatedAt"]);

    return DatasetMetadata(dataUri, updateTime);
  }
}