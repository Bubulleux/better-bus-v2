import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullProvider extends NetworkProvider {
  final ConnectivityStatus connStatus;

  FullProvider({
    required super.api,
    required super.gtfs,
    required this.connStatus,
  });

  factory FullProvider.of(BuildContext context) {
    return context.read<FullProvider>();
  }

  @override
  bool isAvailable() {
    return api.isAvailable() || gtfs.isAvailable();
  }

}
