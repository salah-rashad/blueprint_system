import 'package:blueprint_system/src/models/ruler_options.dart';
import 'package:flutter/material.dart';

import '../floating_node/floating_node.dart';
import '../floating_node/floating_node_controller.dart';
import '../node/node.dart';
import 'ruler_controller.dart';
import 'ruler_painter.dart';

class Ruler extends FloatingNode {
  const Ruler({
    super.id,
    super.key,
    super.blueprint,
    required this.axis,
    this.options = const RulerOptions(),
    super.priority,
  }) : super(
          initPosition: Offset.zero,
        );

  final Axis axis;
  final RulerOptions options;

  @override
  RulerController get init => RulerController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprint,
        priority: priority,
        minSize: minSize,
        initialConstraint:
            axis == Axis.horizontal ? Constraint.X : Constraint.Y,
        sizeFixed: true,
        axis: axis,
      );

  @override
  NodeWidget<FloatingNodeController> get child => (c) {
        return CustomPaint(
          painter: RulerPainter(
            controller: c,
            axis: axis,
            options: options,
            repaint: controller,
          ),
        );
      };
}
