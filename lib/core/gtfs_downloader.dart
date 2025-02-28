import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:better_bus_v2/core/models/gtfs/csv_parser.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_data.dart';
import 'package:better_bus_v2/core/models/gtfs/gtfs_path.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

// TODO: Old Downloader class maybe refactor
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
    // this.gtfsFilePath = "/gtfs.zip",
    // this.gtfsDirPath = "/gtfs",
    // required this.downloadDirectory,
    // required this.gtfsDirectory,
  });

  final Uri dataSetAPI;
  final Uri gtfsFileURL;
  GTFSPaths paths;
  // final String gtfsFilePath;
  // final String gtfsDirPath;
  // final Directory downloadDirectory;
  // final Directory gtfsDirectory;

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
    // TODO: Remove Path provider
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
      files[basename(file.path)] = CSVTable.fromFile(file);
    }
    return files;
  }

  // TODO: forceDownload is Removed Need to be checked

  Future<bool> isDownloadNeeded(DateTime? lastUpdate) async {
    if (lastUpdate == null) {
      return true;
    }
    DatasetMetadata metadata = await getFileMetaData();
    return metadata.updateTime.isAfter(lastUpdate);
  }

  Future<bool> downloadFile() async {
    // TODO: Remove or handle getDownloadWhenWifi
    // bool downloadWhenWifi = await LocalDataHandler.getDownloadWhenWifi();
    // bool isWifiConnected = await ConnectivityChecker.isWifiConnected();
    // if (downloadWhenWifi && !isWifiConnected && !forceDownload) {
    //   return false;
    // }

    late HttpClientResponse? response;
    try {
      DatasetMetadata metadata = await getFileMetaData();

      HttpClient client = HttpClient();
      var request = await client.getUrl(metadata.ressourceUri);
      response = await request.close();
      if (response.statusCode != 200) return false;
    } on Exception {
      return false;
    }

    var bytes = await consolidateHttpClientResponseBytes(response);
    await File(paths.gtfsFilePath).writeAsBytes(bytes);

    await extractZipFile();
    // TODO: Need to be reimplmented
    //await LocalDataHandler.setGTFSDownloadDate(DateTime.now());

    return true;
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
