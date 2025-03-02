import 'package:better_bus_core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullProvider extends NetworkProvider {
  FullProvider({required super.api, required super.gtfs});

  factory FullProvider.of(BuildContext context) {
    return context.read<FullProvider>();
  }
}
