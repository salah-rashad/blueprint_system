import 'package:blueprint_system/src/ruler/ruler_controller.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node_controller.dart';
import 'package:blueprint_system/widgets/node/node.dart';
import 'package:flutter/material.dart';

import 'ruler_painter.dart';

class Ruler extends FloatingNode {
  const Ruler({
    this.tooltip,
    super.id,
    super.key,
    this.textColor,
    this.interval = 100.0,
    this.divisions = 1,
    required this.axis,
    required super.blueprintController,
    this.hideZero = true,
    super.priority,
  })  : assert(
          divisions > 0,
          'The "divisions" property must be greater than zero. If there were no divisions, the grid paper would not paint anything.',
        ),
        super(initPosition: Offset.zero);

  final String? tooltip;
  final Color? textColor;
  final double interval;
  final int divisions;
  final Axis axis;
  final bool hideZero;

  @override
  RulerController get init => RulerController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprintController,
        priority: priority,
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
            textColor: textColor,
            interval: interval,
            divisions: divisions,
            axis: axis,
            hideZero: hideZero,
            repaint: controller,
          ),
        );
      };
}
