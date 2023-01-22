import 'package:flutter/material.dart';

import '../../blueprint_controller.dart';
import '../node/node.dart';
import 'draggable_node_controller.dart';

class DraggableNode extends Node<DraggableNodeController> {
  const DraggableNode({
    super.key,
    super.id,
    super.initPosition,
    super.initSize,
    super.blueprint,
    super.priority,
    super.minSize,
    super.focusEnabled,
    super.child,
    this.feedback,
    this.childWhenDragging,
  });

  final NodeWidget<DraggableNodeController>? feedback;
  final NodeWidget<DraggableNodeController>? childWhenDragging;

  @override
  DraggableNodeController get init => DraggableNodeController(
        id: id,
        initPosition: initPosition,
        initSize: initSize,
        blueprint: blueprint,
        priority: priority,
        minSize: minSize,
      );

  @override
  DraggableNode copyWith({
    String? id,
    NodeWidget<DraggableNodeController>? child,
    NodeWidget<DraggableNodeController>? feedback,
    NodeWidget<DraggableNodeController>? childWhenDragging,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprint,
    int? priority,
    bool? focusEnabled,
  }) {
    return DraggableNode(
      id: id ?? this.id,
      child: child ?? this.child,
      feedback: feedback ?? this.feedback,
      childWhenDragging: childWhenDragging ?? this.childWhenDragging,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprint: blueprint ?? this.blueprint,
      priority: priority ?? this.priority,
      focusEnabled: focusEnabled ?? this.focusEnabled,
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
          rootOverlay: true,
          maxSimultaneousDrags: 1,
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
