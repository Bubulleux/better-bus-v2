class GTFSPaths {
  GTFSPaths(this.gtfsFilePath, this.extractDir);

  // TODO: Maybe another name
  GTFSPaths.broken() : this("", "");

  String gtfsFilePath;
  String extractDir;
}