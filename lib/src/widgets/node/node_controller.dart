import 'dart:math';

import 'package:blueprint_system/src/blueprint_controller.dart';
import 'package:blueprint_system/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class NodeController extends GetxController {
  NodeController({
    this.id,
    required this.initPosition,
    required this.initSize,
    required this.blueprint,
    required this.priority,
  });

  final String? id;
  final Offset initPosition;
  final Size initSize;
  final int priority;

  BlueprintController? blueprint;

  final _position = Rx<Offset>(Offset.zero);
  Offset get position => _position.value;
  set position(Offset value) => _position.value = value;

  final _size = Rx<Size>(Size.zero);
  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  Size get sizeScaled => _size.value * (blueprint!.scale);

  @override
  void onReady() {
    position = initPosition;
    size = initSize;
  }

  static Offset? calculateOffset(
      Offset offset, Size size, BlueprintController blueprint) {
    var rect = blueprint.getRect;
    if (rect == null) return null;

    double x = (offset.dx - rect.left) / blueprint.scale;
    double y = (offset.dy - rect.top) / blueprint.scale;

    x = max(0, min(x, blueprint.maxSize.width - size.width));
    y = max(0, min(y, blueprint.maxSize.height - size.height));

    if (blueprint.snapToGrid) {
      x = x.roundBy(10).toDouble();
      y = y.roundBy(10).toDouble();
    }

    return Offset(x, y);
  }
}
