import 'dart:ui';

import '../../blueprint_controller.dart';
import '../node/node.dart';
import 'fixed_node_controller.dart';

class FixedNode extends Node<FixedNodeController> {
  const FixedNode({
    super.key,
    super.id,
    super.initPosition,
    super.initSize,
    super.child,
    super.blueprint,
    super.priority,
    super.minSize,
    super.focusEnabled,
  });

  @override
  FixedNodeController get init => FixedNodeController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprint,
        priority: priority,
        minSize: minSize,
      );

  @override
  FixedNode copyWith({
    String? id,
    NodeWidget<FixedNodeController>? child,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprint,
    int? priority,
    bool? focusEnabled,
  }) {
    return FixedNode(
      id: id ?? this.id,
      child: child ?? this.child,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprint: blueprint ?? blueprint,
      priority: priority ?? this.priority,
      focusEnabled: focusEnabled ?? this.focusEnabled,
    );
  }
}
