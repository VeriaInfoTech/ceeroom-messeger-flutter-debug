import 'package:flutter/material.dart';

class ResponsiveUtil {
  static const landScapeMaxWidth = 420.0;
  static const portraitMaxWidth = 600.0;
  static const designWidth = 390.0;

  static double ratio(BuildContext context, double factor) {
    double targetWidth = MediaQuery.of(context).size.width;
    return (targetWidth / designWidth) * factor;
  }
}
