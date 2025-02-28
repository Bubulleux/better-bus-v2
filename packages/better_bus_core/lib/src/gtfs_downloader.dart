import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

import 'models/gtfs/csv_parser.dart';
import 'models/gtfs/gtfs_data.dart';
import 'models/gtfs/gtfs_path.dart';


class DatasetMetadata {
  Uri ressourceUri;
  DateTime updateTime;

  DatasetMetadata(this.ressourceUri, this.updateTime);
}

class GTFSDataDownloader {
  GTFSDataDownloader({
    required this.dataSetAPI,
    required this.gtfsFileURL,
    required this.paths,
  });

  final Uri dataSetAPI;
  final Uri gtfsFileURL;
  GTFSPaths paths;


  GTFSData? _gtfsData;

  GTFSDataDownloader.vitalis(GTFSPaths paths)
      : this(
          dataSetAPI: Uri.parse(
              "https://data.grandpoitiers.fr/data-fair/api/v1/datasets/offre-de-transport-du-reseau-vitalis"),
          gtfsFileURL: Uri.parse(
              "https://data.grandpoitiers.fr/data-fair/api/v1/datasets/2gwvlq16siyb7d9m3rqt1pb1/metadata-attachments/gtfs.zip"),
          paths: paths,
        );

  Future<GTFSData?> getData() async {
    if (_gtfsData == null) {
      await downloadFile();
    }
    return _gtfsData ?? (await loadFile());
  }

  Future<GTFSData?> loadFile() async {
    Directory gtfsDir = Directory(paths.extractDir);

    Map<String, CSVTable> files = loadFiles(gtfsDir);

    if (files.isEmpty) {
      return null;
    }
    _gtfsData = GTFSData(files);
    return _gtfsData;
  }

  static Map<String, CSVTable> loadFiles(Directory dir) {
    Map<String, CSVTable> files = {};
    for (FileSystemEntity e in dir.listSync()) {
      if (e is! File) continue;

      File file = e;
      if (!file.path.endsWith(".txt")) continue;
      files[basename(file.path)] = CSVTable.fromFile(file);
    }
    return files;
  }

  Future<bool> downloadFile(
      {void Function(double progress)? onProgress}) async {
    // TODO: Remove or handle getDownloadWhenWifi

    final lastUpdate = await getDownloadDate();

    late http.StreamedResponse response;
    final client = http.Client();
    final List<int> bytes = [];
    var received = 0;
    try {
      DatasetMetadata metadata = await getFileMetaData();
      if (lastUpdate != null && metadata.updateTime.isBefore(lastUpdate)) {
        print("Download abord recent data found");
        return false;
      }

      final request = http.Request("GET", metadata.ressourceUri);
      response = await client.send(request);
      final total = response.contentLength ?? 0;

      await for (var value in response.stream) {
        bytes.addAll(value);
        received += value.length;
        onProgress?.call(received / total);
      }
    } on Exception {
      return false;
    }

    final file = File(paths.gtfsFilePath);
    await file.writeAsBytes(bytes);

    await extractZipFile();
    await setDownloadDate(DateTime.now());

    return true;
  }

  Future<void> forceDownload({void Function(double value)? onProgress}) async {
    await setDownloadDate(null);
    await downloadFile(onProgress: onProgress);
    _gtfsData = await loadFile();
  }

  Future<void> setDownloadDate(DateTime? time) async {
    final file = File("${paths.extractDir}download-date");
    if (time == null) {
      await file.delete();
      return;
    }

    await file.writeAsString(time.millisecondsSinceEpoch.toString());
  }

  Future<DateTime?> getDownloadDate() async {
    final file = File("${paths.extractDir}download-date");
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    final value = int.tryParse(content);
    if (value == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<DatasetMetadata> getFileMetaData() async {
    http.Response res = await http.get(dataSetAPI);
    Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));

    var ressource =
        json["attachments"].firstWhere((e) => e["title"] == "gtfs.zip");

    var uri = Uri.parse(ressource["url"]);
    DateTime updateTime = DateTime.parse(ressource["updatedAt"]);

    return DatasetMetadata(uri, updateTime);
  }

  Future extractZipFile() async {
    await extractFileToDisk(paths.gtfsFilePath, paths.extractDir);
  }
}
