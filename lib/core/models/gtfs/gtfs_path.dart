class GTFSPaths {
  GTFSPaths(this.gtfsFilePath, this.extractDir);

  // TODO: Maybe another name
  GTFSPaths.broken() : this("", "");

  final String gtfsFilePath;
  final String extractDir;
}