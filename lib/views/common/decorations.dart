import 'package:flutter/material.dart';

class CustomDecorations {
  CustomDecorations.of(this.context);

  BuildContext context;
  ThemeData get theme => Theme.of(context);


  BoxDecoration get boxOutlined => BoxDecoration(
    border: Border.all(
      color: theme.primaryColor,
    ),
    borderRadius: borderRadius,
  );

  BoxDecoration get boxBackground => BoxDecoration(
    borderRadius: borderRadius,
    color: Theme.of(context).colorScheme.background,
  );

  static final BorderRadius borderRadius = BorderRadius.circular(20);
  static final simpleShadow = [
    BoxShadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 5, spreadRadius: 3)
  ];
}
