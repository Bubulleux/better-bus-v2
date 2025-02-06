import 'package:better_bus_v2/core/bus_network.dart';
import 'package:test/test.dart';
void main() {
  test("Test Test need to be true",() {
    final network = BusNetwork();
    expect(network.returnTrue(), equals(true));
  });

  // Error Test
  test("Test Test need to be true",() {
    final network = BusNetwork();
    expect(network.returnTrue(), equals(false));
  });
}