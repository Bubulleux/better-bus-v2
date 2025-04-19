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
    return await complete(future(setProgress));
  }

  void setProgress(double value) {
    assert(0 <= value && value <= 1);
    progress = value;
    then?.call();
  }

  final states = const {
    null: CircularProgressIndicator(color: Colors.white24),
    true: Icon(Icons.check, size: 35),
    false: Icon(Icons.error, size: 35),
  };

  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            states[success]!,
            SizedBox(width: 10,),
            Text(label),
          ],
        ),
        progress != null
            ? Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 3),
                height: 20,
                clipBehavior: Clip.hardEdge,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 100),
                  heightFactor: 1,
                  widthFactor: progress,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
