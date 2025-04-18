import 'package:better_bus_v2/model/loading_step.dart';

class RootLoad {
  final internet = LoadingStep(label: "Connextion au system d'information mondial");
  final api = LoadingStep(label: "Hacking de Vitalis");
  final gtfsLoad = LoadingStep(label: "Extration du Réseau");
 final gtfsDownloadLoad = LoadingStep(label: "Téléchargement du Réseau");
  final radar = LoadingStep(label: "Sycronisation avec le Radar");

  List<LoadingStep> get steps => [
    internet,
    api,
    gtfsLoad,
    gtfsDownloadLoad,
    radar,
  ];
}