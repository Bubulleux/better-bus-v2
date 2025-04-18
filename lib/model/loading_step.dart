import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/views/root/loading_page.dart';
import 'package:flutter/material.dart';

class LoadingStep {
  final String label;
  bool? success;
  Object? error;
  VoidCallback? then;
  double? progress;

  LoadingStep({required this.label, this.success});

  Future<bool> complete(Future<bool> future) async {
    assert(success == null);
    try {
      success = await future;
    } catch (e) {
      success = false;
      error = e;
      print(e);
    };
    then?.call();
    return success!;
  }

  Future<bool> completWithProgress(
      Future<bool> Function(OnProgress _) future) async {
    setProgress(0);
    return complete(future(setProgress));
  }

  void setProgress(double value) {
    assert(0 <= value && value <= 1);
    progress = value;
    then?.call();
  }

  final states = const {
    null: CircularProgressIndicator(color: Colors.white24),
    true: Icon(Icons.check),
    false: Icon(Icons.error),
  };

  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            states[success]!,
            Text(label),
          ],
        ),
        progress != null
            ? Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
                child: AnimatedFractionallySizedBox(
                  duration: Duration(milliseconds: 100),
                  heightFactor: 1,
                  widthFactor: progress,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.red,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
