import 'package:flutter/material.dart';

import '../../blueprint_controller.dart';
import '../node/node.dart';
import 'floating_node_controller.dart';

class FloatingNode extends Node<FloatingNodeController> {
  const FloatingNode({
    super.id,
    super.key,
    super.initPosition,
    super.initSize,
    super.blueprint,
    super.child,
    super.priority = 99999,
    super.minSize,
    super.focusEnabled,
    this.constraint = Constraint.NONE,
    this.sizeFixed = true,
    this.responsiveToScreen = false,
  });

  final Constraint constraint;
  final bool sizeFixed;

  /// If true, the node's position will adjust proportionally when the
  /// blueprint's canvas or screen size changes.
  final bool responsiveToScreen;

  @override
  FloatingNodeController get init => FloatingNodeController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprint,
        priority: priority,
        initialConstraint: constraint,
        sizeFixed: sizeFixed,
        minSize: minSize,
        responsiveToScreen: responsiveToScreen,
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
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'constraint': constraint.name,
        'sizeFixed': sizeFixed,
        'responsiveToScreen': responsiveToScreen,
      };

  @override
  FloatingNode copyWith({
    String? id,
    NodeWidget<FloatingNodeController>? child,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprint,
    int? priority,
    bool? focusEnabled,
    Constraint? constraint,
    bool? sizeFixed,
    bool? responsiveToScreen,
  }) {
    return FloatingNode(
      id: id ?? this.id,
      child: child ?? this.child,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprint: blueprint ?? this.blueprint,
      priority: priority ?? this.priority,
      constraint: constraint ?? this.constraint,
      sizeFixed: sizeFixed ?? this.sizeFixed,
      focusEnabled: focusEnabled ?? this.focusEnabled,
      responsiveToScreen: responsiveToScreen ?? this.responsiveToScreen,
    );
  }
}
