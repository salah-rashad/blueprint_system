import 'package:blueprint_system/src/blueprint_controller.dart';
import 'package:blueprint_system/src/widgets/floating_node/floating_node_controller.dart';
import 'package:blueprint_system/src/widgets/node/node.dart';
import 'package:flutter/material.dart';

class FloatingNode extends Node<FloatingNodeController> {
  const FloatingNode({
    super.id,
    super.key,
    super.initPosition,
    super.initSize,
    super.blueprintController,
    super.child,
    super.priority = 99999,
    this.constraint = Constraint.NONE,
    this.sizeFixed = true,
  });

  final Constraint constraint;
  final bool sizeFixed;

  @override
  FloatingNodeController get init => FloatingNodeController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprintController,
        priority: priority,
        initialConstraint: constraint,
        sizeFixed: sizeFixed,
      );

  @override
  Widget builder(FloatingNodeController controller) {
    return Transform.scale(
      alignment: Alignment.topLeft,
      scale: sizeFixed ? (1 / controller.blueprint!.scale) : 1.0,
      child: super.builder(controller),
    );
  }

  @override
  FloatingNode copyWith({
    String? id,
    NodeWidget<FloatingNodeController>? child,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprintController,
    int? priority,
    Constraint? constraint,
    bool? sizeFixed,
  }) {
    return FloatingNode(
      id: id ?? this.id,
      child: child ?? this.child,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprintController: blueprintController ?? this.blueprintController,
      priority: priority ?? this.priority,
      constraint: constraint ?? this.constraint,
      sizeFixed: sizeFixed ?? this.sizeFixed,
    );
  }
}
