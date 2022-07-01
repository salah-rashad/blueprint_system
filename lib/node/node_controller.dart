import 'dart:math';

import 'package:blueprint_system/blueprint_controller.dart';
import 'package:blueprint_system/src/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NodeController extends GetxController {
  Offset? initPosition;
  Size? initSize;
  NodeController({this.initPosition, this.initSize});

  BlueprintController? blueprint;

  final _position = Rx<Offset>(Offset.zero);
  final _size = Rx<Size>(Size.zero);

  Offset get position => _position.value;
  set position(Offset value) => _position.value = value;

  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  double get blueprintScale => blueprint!.scale;

  @override
  void onReady() {
    if (initPosition != null) {
      position = initPosition!;
    } else {
      position = initPosition = const Offset(0, 0);
    }

    if (initSize != null) {
      size = initSize!;
    } else {
      size = initSize = const Size(200, 50);
    }
  }

  void onDrag(DraggableDetails details) {
    final blueprintRect = blueprint!.getRect;
    if (blueprintRect == null) return;

    double x = (details.offset.dx - blueprintRect.left) / blueprintScale;
    double y = (details.offset.dy - blueprintRect.top) / blueprintScale;

    x = max(0, x);
    y = max(0, y);

    if (blueprint!.snapToGrid) {
      x = x.roundTens().toDouble();
      y = y.roundTens().toDouble();
    }

    position = Offset(x, y);

    blueprint!.updateCanvasSize();
    blueprint!.animateTo(this);
  }
}
