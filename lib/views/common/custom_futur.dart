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
    this.onError,
    this.onLoading,
    this.initData,
    this.refreshIndicator,
    this.errorTest,
    this.automaticRefresh,
  }) : super(key: key);

  final FutureFunction<T> future;
  final T? initData;
  final WidgetBuilderData onData;
  final WidgetBuilderError? onError;
  final WidgetBuilder? onLoading;
  final WidgetRefresh? refreshIndicator;
  final ExceptionTest? errorTest;
  final Duration? automaticRefresh;

  @override
  State<CustomFutureBuilder> createState() => CustomFutureBuilderState<T>();
}

class CustomFutureBuilderState<T> extends State<CustomFutureBuilder> {
  T? data;
  CustomError? error;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    data = widget.initData;
    if (data == null){
      refresh();
    }
  }

  Future refresh() async{
    setState(() {
      isLoading = true;
    });
    await hideRefresh();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

  }

  Future hideRefresh() async {
    error = null;

    try {
      data = await widget.future();

      if (widget.errorTest != null){
        error = widget.errorTest!(data);
      }
    } on Exception catch(e) {
      error = e.toError();
    } on Error catch(e) {
      error = e is CustomError ? e : CustomError(e.toString(), Icons.error, false);
    }


    if (error == null && widget.automaticRefresh != null) {
      Future.delayed(widget.automaticRefresh!, refresh);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget getRefreshIndicator({required Widget child}) {
    if (widget.refreshIndicator == null) {
      return Container(child:  child,);
    } else {
      return widget.refreshIndicator!(context, child, hideRefresh);
    }
  }

  Widget getOnLoadingScreen() {
    return widget.onLoading != null ? widget.onLoading!(context) : const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      getOnLoadingScreen();
    }

    if (error != null){
      if (widget.onError != null){
        return widget.onError!(context, error!, refresh);
      }

      return error!.build(context, refresh);

    } else if (data != null) {
      return getRefreshIndicator(child: widget.onData(context, data, refresh));
    }

    return Container();
  }
}