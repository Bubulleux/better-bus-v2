import 'dart:ffi';

import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/material.dart';

typedef WidgetBuilderData<T> = Widget Function(
    BuildContext context, T data, VoidCallback refresh);

typedef WidgetBuilderError = Widget Function(
    BuildContext, CustomError e, VoidCallback refresh);

typedef FutureFunction<T> = Future<T> Function();

typedef ExceptionTest = CustomError? Function(dynamic data);

typedef WidgetRefresh = RefreshIndicator Function(
    BuildContext context, Widget child, FutureFunction future,);

class CustomFutureBuilder<T> extends StatefulWidget {
  const CustomFutureBuilder({
    Key? key,
    required this.future,
    required this.onData,
    required this.onError,
    this.onLoading,
    this.initData,
    this.refreshIndicator,
    this.errorTest,
  }) : super(key: key);

  final FutureFunction<T> future;
  final T? initData;
  final WidgetBuilderData onData;
  final WidgetBuilderError onError;
  final WidgetBuilder? onLoading;
  final WidgetRefresh? refreshIndicator;
  final ExceptionTest? errorTest;

  @override
  State<CustomFutureBuilder> createState() => CustomFutureBuilderState<T>();
}

class CustomFutureBuilderState<T> extends State<CustomFutureBuilder> {
  T? data;
  CustomError? error;

  @override
  void initState() {
    super.initState();
    data = widget.initData;
    if (data == null){
      refresh();
    }
  }

  Future refresh() async {
    error = null;
    try {
      data = await widget.future();

      if (data == null){
        error = DataIsNull().toError();
      } else if (widget.errorTest != null){
        error = widget.errorTest!(data);
      }
    } on Exception catch(e) {
      data = null;
      error = e.toError();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget getRefreshIndicator({required Widget child}) {
    if (widget.refreshIndicator == null) {
      return Container(child:  child,);
    } else {
      return widget.refreshIndicator!(context, child, refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null){
      return widget.onError(context, error!, refresh);
    } else if (data != null) {
      return getRefreshIndicator(child: widget.onData(context, data, refresh));
    } else {
      if (widget.onLoading == null) {
        return Center(child: CircularProgressIndicator());
      }
      return widget.onLoading!(context);
    }
  }
}

class DataIsNull implements Exception{
  @override
  String toString() => "Data return are null";

}