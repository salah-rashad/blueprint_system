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
  num roundTens() {
    num result = floor();
    num lastNum = result % 10;

    if (lastNum >= 5) {
      num remain = 10 - lastNum;
      result += remain;
    } else {
      result -= lastNum;
    }

    return result;
  }
}
