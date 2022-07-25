import 'package:flutter/material.dart';

typedef WidgetBuilderData<T> = Widget Function(
    BuildContext context, T data, VoidCallback refresh);

typedef WidgetBuilderError = Widget Function(
    BuildContext, Exception e, VoidCallback refresh);

typedef FutureFunction<T> = Future<T> Function();

typedef ExceptionTest<T> = Exception? Function(T data);

typedef WidgetRefresh = RefreshIndicator Function(
    BuildContext context, FutureFunction future, Widget child);

class CustomFutureBuilder<T> extends StatefulWidget {
  const CustomFutureBuilder({
    Key? key,
    required this.future,
    required this.onData,
    required this.onError,
    required this.onLoading,
    this.initData,
    this.refreshIndicator,
    this.exceptionTest,
  }) : super(key: key);

  final FutureFunction<T> future;
  final T? initData;
  final WidgetBuilderData onData;
  final WidgetBuilderError onError;
  final WidgetBuilder onLoading;
  final WidgetRefresh? refreshIndicator;
  final ExceptionTest<T>? exceptionTest;

  @override
  State<CustomFutureBuilder> createState() => CustomFutureBuilderState<T>();
}

class CustomFutureBuilderState<T> extends State<CustomFutureBuilder> {
  T? data;
  Exception? exception;

  @override
  void initState() {
    super.initState();
    data = widget.initData;
  }

  Future refresh() async {
    exception = null;
    try {
      data = await widget.future();

      if (data == null){
        exception = DataIsNull();
      } else if (widget.exceptionTest != null){
        exception = widget.exceptionTest!(data);
      }
    } on Exception catch(e) {
      data = null;
      exception = e;
    }
    setState(() {});
  }

  Widget getRefreshIndicator({required Widget child}) {
    if (widget.refreshIndicator == null) {
      return Container(child:  child,);
    } else {
      return widget.refreshIndicator!(context, refresh, child);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (exception != null){
      return widget.onError(context, exception!, refresh);
    } else if (data != null) {
      return getRefreshIndicator(child: widget.onData(context, data, refresh));
    } else {
      return widget.onLoading(context);
    }
  }
}

class DataIsNull implements Exception {

  @override
  String toString() {
    return "Data return was null";
  }
}