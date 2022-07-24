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

  static final BorderRadius borderRadius = BorderRadius.circular(20);
}