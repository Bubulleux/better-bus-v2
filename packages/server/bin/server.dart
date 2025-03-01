import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'package:better_bus_core/core.dart';

final provider = GTFSProvider.vitalis(ServerPaths());
final reports = ReportsHandler(provider);

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/count', _countReports)
  ..get('sendReport/<stationId>', _sendReport);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Response _countReports(Request request) {
  return Response.ok("Count report: ${reports.countReports()}");
}

Future<Response> _sendReport(Request request) async {
  final stationId = request.params["stationId"];
  if (stationId == null) {
    return Response.badRequest(body: "Missing stationId");
  }
  final success = await reports.sendReport(int.parse(stationId));
  if (!success) {
    Response.badRequest(body: "Station does not existe");
  }
  return Response.ok("Report sent");
}

Future<bool> initProvider() async {
  final success = await provider.init();
  if (!success) {
    throw "Provider failed to init";
  }
  print("Provider init Success !!");
  return true;
}

void main(List<String> args) async {
  await initProvider();
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
