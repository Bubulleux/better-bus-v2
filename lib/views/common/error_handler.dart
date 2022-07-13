import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void printError(context, err) {

    if (kDebugMode) {
      print("Error:\n$err");
    }
    AlertDialog alert = AlertDialog(
      title: const Text("Error"),
      content: Text(err.toString()),
      actions: [
        TextButton(onPressed: () {}, child: const Text("OK"))
      ],
    );

    showDialog(context: context, builder: (context) => alert);
  }


}