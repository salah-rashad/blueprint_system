import 'package:blueprint_system/widgets/node/node.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

import 'draggable_node_controller.dart';

class DraggableNode extends Node<DraggableNodeController> {
  DraggableNode({
    super.key,
    super.initPosition,
    super.initSize,
    required super.child,
    this.feedback,
    this.childWhenDragging,
  });

  final NodeWidget<DraggableNodeController>? feedback;
  final NodeWidget<DraggableNodeController>? childWhenDragging;

  @override
  DraggableNodeController get controller =>
      Get.put(DraggableNodeController(initPosition, initSize), tag: id);

  @protected
  @override
  Widget builder(DraggableNodeController controller) {
    return Listener(
      onPointerDown: (details) {
        controller.dragAnchor = details.localPosition;
      },
      child: Draggable(
        feedback: scaleSafeWidget(child: child(controller)),
        childWhenDragging:
            childWhenDragging?.call(controller) ?? const SizedBox.shrink(),
        onDragEnd: controller.onDragEnd,
        onDragStarted: controller.onDragStarted,
        onDragUpdate: controller.onDragUpdate,
        dragAnchorStrategy: controller.dragAnchorStrategy,
        child: child(controller),
      ),
    );
  }

  Widget scaleSafeWidget({required Widget child}) {
    return Transform.scale(
      scale: controller.blueprint.scale,
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
