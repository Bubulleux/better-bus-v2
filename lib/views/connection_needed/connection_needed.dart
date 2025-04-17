import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/material.dart';

class ConnectionNeeded extends StatelessWidget {
  const ConnectionNeeded({this.onRefresh, super.key});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: CustomErrors.noInternet.build(context, onRefresh),
    );
  }
}
