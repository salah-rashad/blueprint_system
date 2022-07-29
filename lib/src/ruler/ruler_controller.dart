import 'package:blueprint_system/widgets/floating_node/floating_node_controller.dart';
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

    Size? cameraSize = blueprint?.widgetRect?.size;
    Offset? cameraPosition = blueprint?.cameraPosition;

    if (cameraSize == null || cameraPosition == null) {
      return blueprint?.size ?? initSize;
    }

    double scale = blueprint?.scale ?? 1.0;
    var resolvedWidth = cameraSize.width / scale + cameraPosition.dx / scale;
    var resolvedHeight = cameraSize.height / scale + cameraPosition.dy / scale;

    return axis == Axis.horizontal
        ? Size(resolvedWidth, cameraSize.height)
        : Size(cameraSize.width, resolvedHeight);
  }
}
