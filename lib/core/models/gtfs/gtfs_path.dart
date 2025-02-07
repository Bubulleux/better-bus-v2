class GTFSPaths {
  GTFSPaths(this.gtfsFilePath, this.extractDir);

  GTFSPaths.broken() : this("", "");

  final String gtfsFilePath;
  final String extractDir;
}