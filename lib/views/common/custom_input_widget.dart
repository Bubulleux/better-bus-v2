import 'package:flutter/material.dart';

class CustomInputWidget extends StatelessWidget {
  CustomInputWidget({required this.child, this.onTap, BorderRadius? borderRadius, super.key}){
    this.borderRadius = borderRadius ?? BorderRadius.circular(20);
  }
  final Widget child;

  final void Function()? onTap;
  late final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Material(
        borderRadius: borderRadius,
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: child,
          ),
        ),
      ),
    );
  }
}