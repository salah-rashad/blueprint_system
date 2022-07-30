import 'package:blueprint_system/src/blueprint_controller.dart';
import 'package:blueprint_system/src/widgets/node/node.dart';
import 'package:flutter/material.dart';

import 'draggable_node_controller.dart';

class DraggableNode extends Node<DraggableNodeController> {
  const DraggableNode({
    super.id,
    super.key,
    super.child,
    this.feedback,
    this.childWhenDragging,
    super.blueprintController,
    super.initPosition,
    super.initSize,
    super.priority,
  });

  final NodeWidget<DraggableNodeController>? feedback;
  final NodeWidget<DraggableNodeController>? childWhenDragging;

  @override
  DraggableNodeController get init => DraggableNodeController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprintController,
        priority: priority,
      );

  @override
  DraggableNode copyWith({
    String? id,
    NodeWidget<DraggableNodeController>? child,
    NodeWidget<DraggableNodeController>? feedback,
    NodeWidget<DraggableNodeController>? childWhenDragging,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprintController,
    int? priority,
  }) {
    return DraggableNode(
      id: id ?? this.id,
      child: child ?? this.child,
      feedback: feedback ?? this.feedback,
      childWhenDragging: childWhenDragging ?? this.childWhenDragging,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprintController: blueprintController ?? this.blueprintController,
      priority: priority ?? this.priority,
    );
  }

  @override
  Widget builder(DraggableNodeController controller) {
    return Listener(
      onPointerDown: (details) {
        controller.dragAnchor = details.localPosition;
      },
      child: MouseRegion(
        cursor: controller.mouseCursor,
        child: Draggable<DraggableNode>(
          data: this,
          feedback: scaleSafeWidget(child: super.builder(controller)),
          childWhenDragging:
              childWhenDragging?.call(controller) ?? const SizedBox.shrink(),
          onDragStarted: controller.onDragStarted,
          onDragUpdate: controller.onDragUpdate,
          onDragEnd: controller.onDragEnd,
          dragAnchorStrategy: controller.dragAnchorStrategy,
          child: super.builder(controller),
        ),
      ),
    );
  }

  Widget scaleSafeWidget({required Widget child}) {
    return Transform.scale(
      scale: controller.blueprint!.scale,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: controller.size.width,
        height: controller.size.height,
        child: Material(
          type: MaterialType.transparency,
          child: child,
        ),
      ),
    );
  }
}
