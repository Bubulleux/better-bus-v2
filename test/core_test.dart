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

  test("Test stations", () async {
    expect(network.isAvailable(), true);
    expect(await network.getStations(), isNotEmpty);
  });
}