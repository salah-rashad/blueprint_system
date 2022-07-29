import 'dart:math';

import 'package:flutter/material.dart';

// A useful extension for getting absolute coordinates of a widget
// (found somewhere in SO)
extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension IntExtensions on num {
  num roundBy(num v) {
    num result = floor();
    num lastNumbers = result % v;

    if (lastNumbers >= v/2) {
      num remain = v - lastNumbers;
      result += remain;
    } else {
      result -= lastNumbers;
    }

    return result;
  }

  // num roundBy(num v, [num start = 0]) {
  //   num result = floor();
  //   num lastNum = result % v;

  //   if (lastNum > start) {
  //     result = ((this - start) ~/ v) * v + v;
  //   }

  //   return result;
  // }

  bool get isInteger => this is int || this == roundToDouble();
}

extension ColorExtensions on Color {
  static Color random() {
    int length = Colors.primaries.length;
    int rnd = Random().nextInt(length);
    return Colors.primaries[rnd];
  }
}
