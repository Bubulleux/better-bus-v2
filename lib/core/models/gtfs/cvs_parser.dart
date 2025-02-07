import 'dart:io';

class CSVTable extends Iterable{
  late final List<String>? keys;
  late List<List<String>> table;

  CSVTable(this.keys, this.table);

  CSVTable.fromFile(File file, [bool firstRawIsTitle = true]) {
    List<String> lines = file.readAsLinesSync();
    if (firstRawIsTitle) {
      String titles = lines.removeAt(0);
      keys = titles.split(",");
    }

    table = [];
    for (String line in lines) {
      table.add(line.split(","));
    }
  }

  Map<String, String> getLine(int index) {
    return rowToMap(table[index]);
  }

  Map<String, String> rowToMap(List<String> row) {
    return Map.fromIterables(keys!, row);
  }

  @override
  Iterator get iterator => table.map(rowToMap).iterator;
}
