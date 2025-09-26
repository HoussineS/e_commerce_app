import 'package:flutter/material.dart';


class ScreenConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double screenRealHeight;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    screenWidth = size.width;
    screenHeight = size.height;
    screenRealHeight =
        screenHeight - AppBar().preferredSize.height - mediaQuery.padding.top;
  }
}
