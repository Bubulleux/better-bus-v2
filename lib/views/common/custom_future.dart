import 'package:better_bus_v2/error_handler/custom_error.dart';
import 'package:flutter/material.dart';

typedef WidgetBuilderData<T> = Widget Function(
    BuildContext context, T data, VoidCallback refresh);

typedef WidgetBuilderError = Widget Function(
    BuildContext, CustomError e, VoidCallback refresh);

typedef FutureFunction<T> = Future<T> Function();

typedef ExceptionTest = CustomError? Function(dynamic data);

typedef WidgetRefresh = RefreshIndicator Function(
  BuildContext context,
  Widget child,
  FutureFunction future,
);

class CustomFutureBuilder<T> extends StatefulWidget {
  const CustomFutureBuilder({
    super.key,
    required this.future,
    required this.onData,
    this.onError,
    this.onLoading,
    this.initData,
    this.refreshIndicator,
    this.errorTest,
    this.automaticRefresh,
  });

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

class CustomFutureBuilderState<T> extends State<CustomFutureBuilder>
    with WidgetsBindingObserver {
  T? data;
  CustomError? error;
  Future<T>? future;

  bool get isLoading => future != null;
  AppLifecycleState? _notification;
  bool needRefresh = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    data = widget.initData;
    if (data == null) {
      refresh();
    }

    if (widget.automaticRefresh != null) {
      Future.delayed(widget.automaticRefresh!, autoRefresh);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notification = state;
    if (state == AppLifecycleState.resumed && needRefresh) {
      autoRefresh();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<T?> refresh() {
    if (!mounted) {
      needRefresh = true;
      return Future.value(null);
    }
    needRefresh = false;
    error = null;
    future = widget.future() as Future<T>?;
    future!.then((v) => onData(v), onError: onError);
    return future!;
  }

  void onData(T value) {
    print("Mounted: $mounted");
    if (error != null || !mounted) return;

    setState(() {
      future = null;
      error = widget.errorTest?.call(value);
      data = value;
    });
  }

  T? onError(Object error, StackTrace stack) {
    print("Future build got error:");
    print(error);
    print(stack);
    if (!mounted) return null;
    setState(() {
      future = null;
      error = error;
    });
    return null;
  }

  void autoRefresh() {
    if (_notification == AppLifecycleState.paused) {
      needRefresh = true;
      return;
    }

    refresh();
    needRefresh = false;
    if (widget.automaticRefresh != null && error == null && mounted) {
      Future.delayed(widget.automaticRefresh!, autoRefresh);
    }
  }

  // Future hideRefresh() async {
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   try {
  //     data = await widget.future();
  //     error = null;
  //
  //     if (widget.errorTest != null){
  //       error = widget.errorTest!(data);
  //     }
  //   } on Exception catch(e) {
  //    error = e.toError();
  //   } on Error catch(e) {
  //     error = e is CustomError ? e : CustomError(e.toString(), Icons.error, false);
  //   }
  //   isLoading = false;
  //
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  Widget getRefreshIndicator({required Widget child}) {
    if (widget.refreshIndicator == null) {
      return Container(
        child: child,
      );
    } else {
      return widget.refreshIndicator!(context, child, refresh);
    }
  }

  Widget getOnLoadingScreen() {
    return widget.onLoading != null
        ? widget.onLoading!(context)
        : const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return getOnLoadingScreen();
    }
    if (needRefresh) refresh();
    if (data is! T) {
      error = CustomError("Not the right type", null, false);
    }

    if (error != null) {
      if (widget.onError != null) {
        return widget.onError!(context, error!, refresh);
      }

      return error!.build(context, refresh);
    }

    return getRefreshIndicator(child: widget.onData(context, data, refresh));
  }
}
