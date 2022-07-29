import 'dart:ui';

import 'package:blueprint_system/blueprint_controller.dart';
import 'package:blueprint_system/widgets/node/node.dart';

import 'fixed_node_controller.dart';

class FixedNode extends Node<FixedNodeController> {
  const FixedNode({
    super.key,
    super.id,
    super.child,
    super.initPosition,
    super.initSize,
    super.blueprintController,
    super.priority,
  });

  @override
  FixedNodeController get init => FixedNodeController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprintController,
        priority: priority,
      );

  @override
  FixedNode copyWith({
    String? id,
    NodeWidget<FixedNodeController>? child,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprintController,
    int? priority,
  }) {
    return FixedNode(
      id: id ?? this.id,
      child: child ?? this.child,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprintController: blueprintController ?? this.blueprintController,
      priority: priority ?? this.priority,
    );
  }
}
