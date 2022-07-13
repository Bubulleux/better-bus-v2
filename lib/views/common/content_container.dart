import 'package:flutter/material.dart';

BoxDecoration commonDecoration(context) {
  return BoxDecoration(
      color: Theme.of(context).backgroundColor,
      borderRadius: BorderRadius.circular(40));
}

class NormalContentContainer extends StatelessWidget {
  const NormalContentContainer({this.child, this.height, Key? key})
      : super(key: key);

  final Widget? child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: commonDecoration(context),
      child: child,
    );
  }
}

class ClickableContentContainer extends StatelessWidget {
  const ClickableContentContainer(
      {this.child, this.height, this.onPressed, this.onLongPressed, Key? key})
      : super(key: key);

  final Widget? child;
  final double? height;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed ?? (() {}),
        onLongPress: onLongPressed,
        child: SizedBox(
          height: height,
          width: double.infinity,
          //decoration: commonDecoration(context),
          child: child,
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        )
        ),
      );
  }
}
