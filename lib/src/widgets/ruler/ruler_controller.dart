import 'package:blueprint_system/src/widgets/floating_node/floating_node_controller.dart';
import 'package:flutter/material.dart';

class RulerController extends FloatingNodeController {
  RulerController({
    required super.id,
    required super.initPosition,
    required super.initSize,
    required super.blueprint,
    required super.priority,
    required super.initialConstraint,
    required super.sizeFixed,
    required this.axis,
  });

  final Axis axis;

  @override
  Size get size {
    // This is updating ruler size in response to the blueprint widget's size
    // and blueprint's scale in order to improve performance. For example,
    // if the canvas size is (50,000 px), the ruler will have the same size,
    // resulting in the ruler being rendered at full size,
    // causing stuttering and framerate drops.

    Size? camSize = blueprint?.cameraSize;
    Offset? camPos = blueprint?.cameraPosition;

    if (camSize == null || camPos == null) {
      return blueprint?.size ?? initSize;
    }

    double scale = blueprint?.scale ?? 1.0;
    var resolvedWidth = (camSize.width + camPos.dx) / scale;
    var resolvedHeight = (camSize.height + camPos.dy) / scale;

    return axis == Axis.horizontal
        ? Size(resolvedWidth, camSize.height)
        : Size(camSize.width, resolvedHeight);
  }
}
