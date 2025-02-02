import 'package:flutter/material.dart';

BoxDecoration commonDecoration(context) {
  return BoxDecoration(
      color: Theme.of(context).colorScheme.background,
      borderRadius: BorderRadius.circular(40));
}

class NormalContentContainer extends StatelessWidget {
  const NormalContentContainer({this.child, this.height, super.key});

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

class CustomContentContainer extends StatelessWidget {
  CustomContentContainer({
    this.child,
    this.onTap,
    this.onLongTap,
    this.color,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
    super.key,
  }) {
    _padding = padding ?? const EdgeInsets.all(15);
    _margin = margin ?? EdgeInsets.zero;
    _borderRadius = borderRadius ?? BorderRadius.circular(20);
  }

  final Widget? child;
  late final EdgeInsets _padding;
  late final EdgeInsets _margin;
  late final BorderRadius _borderRadius;
  final void Function()? onTap;
  final void Function()? onLongTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _margin,
      child: Material(
        color: color ?? Theme.of(context).colorScheme.background,
        borderRadius: _borderRadius,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongTap,
          borderRadius: _borderRadius,
          child: Container(
            padding: _padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
