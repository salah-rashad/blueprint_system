import 'dart:math';

import 'package:flutter/material.dart';

extension GlobalKeyExtension on GlobalKey {
  /// A useful extension for getting absolute coordinates of a widget
  /// (found somewhere in SO)
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
  /// Calculates the nearest number to [this] by [v].<br/>
  /// For example:
  /// if [v] = 10,<br/>
  /// it will calculate the nearest number of the 10s to [this] number
  /// ```
  /// 43.roundBy(10); // 40
  /// 16.roundBy(10); // 20
  /// 68.roundBy(15); // 75
  /// 49.99999.roundBy(100) // 0
  /// 50.roundBy(100) // 100
  /// ```
  num roundBy(num v) {
    num result = floor();
    num lastNumbers = result % v;

    if (lastNumbers >= v / 2) {
      num remain = v - lastNumbers;
      result += remain;
    } else {
      result -= lastNumbers;
    }

    return result;
  }

  /// checks if [this] number is `int` (integer) or not.
  bool get isInteger => this is int || this == roundToDouble();
}

extension ColorExtensions on Color {
  /// Returns a random color from the material design primary colors.
  static Color random() {
    int length = Colors.primaries.length;
    int rnd = Random().nextInt(length);
    return Colors.primaries[rnd];
  }
}

// extension GetItExtensions on GetIt {
//   T put<T extends Object>(
//     T instance, {
//     String? tag,
//   }) {
//     bool isRegestered = isRegistered<T>(instanceName: tag);

//     if (isRegestered) {
//       return get<T>(instanceName: tag);
//     } else {
//       registerSingleton<T>(instance);
//       return get<T>(instanceName: tag);
//     }
//   }

//   T putLazy<T extends Object>(
//     T Function() instance, {
//     String? tag,
//   })  {
//     bool isRegestered = isRegistered<T>(instanceName: tag);

//     if (isRegestered) {
//       return get<T>(instanceName: tag);
//     } else {
//       registerLazySingleton<T>(instance);
//       return get<T>(instanceName: tag);
//     }
//   }
// }
