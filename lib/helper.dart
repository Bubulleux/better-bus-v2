import 'package:flutter/material.dart';


Color colorFromHex(String hex) {
  return Color(int.parse(hex.replaceAll("#", "0xff")));
}