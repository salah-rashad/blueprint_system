import 'package:blueprint_system/blueprint_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

import 'size_handle_controller.dart';

class SizeHandle extends StatelessWidget {
  final NodeController nodeController;
  final Alignment alignment;
  const SizeHandle(this.nodeController, this.alignment, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<SizeHandleController>(
      init: SizeHandleController(nodeController, alignment),
      tag: nodeController.id.toString() + alignment.toString(),
      builder: (controller) {
        return Positioned.fromRect(
          rect: Rect.fromCenter(
            center: controller.center,
            width: controller.size.width,
            height: controller.size.height,
          ),
          child: Listener(
            onPointerDown: (details) {
              controller.dragAnchor = details.localPosition;
            },
            child: MouseRegion(
              cursor: controller.cursor,
              onEnter: (e) => controller.hover = true,
              onExit: (e) => controller.hover = false,
              child: Draggable(
                feedback: const SizedBox.shrink(),
                childWhenDragging: const SizedBox.shrink(),
                onDragStarted: controller.onDragStarted,
                onDragUpdate: controller.onDragUpdate,
                onDragEnd: controller.onDragEnd,
                dragAnchorStrategy: controller.dragAnchorStrategy,
                axis: controller.getAxis(),
                child: GestureDetector(
                  onTapDown: (_) => controller.show = true,
                  onTapCancel: () => controller.show = false,
                  onTapUp: (_) => controller.show = false,
                  child: AnimatedOpacity(
                    opacity: controller.show
                        ? 0.0
                        : controller.hover
                            ? 0.0
                            : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: child(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget child() {
    return Container(color: Colors.white);
  }

  Widget scaleSafeWidget(
      {required Widget child, required SizeHandleController controller}) {
    return Transform.scale(
      scale: controller.nodeController.blueprint!.scale,
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
