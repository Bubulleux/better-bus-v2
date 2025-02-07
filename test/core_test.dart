import 'package:better_bus_v2/core/api_provider.dart';
import 'package:better_bus_v2/core/bus_network.dart';
import 'package:test/test.dart';
void main() {
  ApiProvider api = ApiProvider.vitalis();
  testNetwork(api);
}

void testNetwork(BusNetwork network) async {
  test("Test init", ()  async {
    expect(await network.init(), true);
    expect(network.isAvailable(), true);
  });

  test("Test getStations", () async {
    expect(await network.getStations(), isNotEmpty);
  });

  test("Test getAllLines", () async {
    expect(await network.getAllLines(), isNotEmpty);
  });

  test("Test getLine from stop", () async {
    final stations = await network.getStations();
    stations.shuffle();
    final nd = stations.firstWhere((e) => e.name.startsWith("Notre-"));
    expect(nd, isNotNull);
    expect(await network.getPassingLines(stations.first), isNotEmpty);
    expect(await network.getPassingLines(nd), isNotEmpty);
  });
}
