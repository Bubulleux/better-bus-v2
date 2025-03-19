import 'package:flutter/cupertino.dart';

extension Separator on Iterable<Widget> {
  Iterable<Widget> separate(Widget element, {bool before = false, bool after = false}) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      if (before) yield element;
      yield iterator.current;
      while(iterator.moveNext()) {
        yield element;
        yield iterator.current;
      }
      if (after) yield element;
    }
  }
}