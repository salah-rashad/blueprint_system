library blueprint_system;

import 'package:blueprint_system/blueprint_controller.dart';
import 'package:blueprint_system/src/ruler/ruler.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node_controller.dart';
import 'package:blueprint_system/widgets/node/node.dart';
import 'package:blueprint_system/widgets/node/node_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

class Blueprint extends StatefulWidget {
  const Blueprint({
    super.key,
    this.controller,
    this.children,
    this.backgroundColor,
    this.minSize,
    this.maxSize,
    this.verticalRulerTextColor,
    this.horizontalRulerTextColor,
    this.followNewAddedNodes,
  });

  final BlueprintController? controller;
  final List<Node>? children;
  final Color? backgroundColor;
  final Size? minSize;
  final Size? maxSize;
  final Color? verticalRulerTextColor;
  final Color? horizontalRulerTextColor;
  final bool? followNewAddedNodes;

  static bool get isLogEnabled => Get.isLogEnable;
  static set isLogEnabled(bool value) => Get.isLogEnable = value;

  @override
  State<Blueprint> createState() => _BlueprintState();
}

class _BlueprintState extends State<Blueprint> {
  String hRulerId(String blueprintId) => " // Horizontal Ruler$blueprintId";
  String vRulerId(String blueprintId) => " // Vertical Ruler$blueprintId";

  @override
  Widget build(BuildContext context) {
    return GetX<BlueprintController>(
      init: widget.controller ?? BlueprintController.instance,
      tag: widget.controller?.id,
      autoRemove: true,
      initState: (state) {
        var ctrl = state.controller;
        if (ctrl != null) {
          ctrl.minSize = widget.minSize ?? Size.zero;
          ctrl.maxSize = widget.maxSize ?? Size.infinite;
          ctrl.followNewAddedNodes = widget.followNewAddedNodes ?? true;

          if (widget.children != null) {
            ctrl.addNodes(widget.children!);
          }
        }
      },
      builder: (controller) => Container(
        color: widget.backgroundColor ?? Colors.grey.shade900,
        key: controller.widgetKey,
        child: InteractiveViewer(
          transformationController: controller.transformationController,
          clipBehavior: Clip.antiAlias,
          onInteractionStart: (d) {
            controller.onInteractionStart.invoke(d);
            controller.onInteractionStart_(d);
          },
          onInteractionEnd: controller.onInteractionEnd.invoke,
          onInteractionUpdate: controller.onInteractionUpdate.invoke,
          minScale: 0.1,
          maxScale: 1.0,
          constrained: false,
          child: Container(
            color: widget.backgroundColor ?? Colors.grey.shade900,
            width: controller.size.width,
            height: controller.size.height,
            child: DragTarget<Node>(
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  key: controller.stackKey,
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: controller.showGrid ? 1.0 : 0.0,
                        duration: 200.milliseconds,
                        child: GridPaper(
                          color: Colors.white.withOpacity(0.1),
                          divisions: 2,
                          interval: 100,
                        ),
                      ),
                    ),
                    ...controller.nodes
                      ..sort((a, b) => a.priority.compareTo(b.priority)),
                    Ruler(
                      tooltip: "X direction",
                      id: hRulerId(controller.id),
                      axis: Axis.horizontal,
                      blueprintController: controller,
                      textColor: widget.verticalRulerTextColor,
                    ),
                    Ruler(
                      tooltip: "Y direction",
                      id: vRulerId(controller.id),
                      axis: Axis.vertical,
                      blueprintController: controller,
                      textColor: widget.horizontalRulerTextColor,
                    ),
                  ],
                );
              },
              onAcceptWithDetails: (details) {
                var droppedNode = details.data;

                if (droppedNode.blueprintController != null) {
                  // disabling this feature until this issue gets fixed
                  // https://github.com/salah-rashad/blueprint_system/issues/2
                  return;
                }

                var offset = NodeController.calculateOffset(
                  details.offset,
                  droppedNode.initSize,
                  controller,
                );
                var newNode = droppedNode.copyWith(initPosition: offset);

                if (newNode is FloatingNode) {
                  controller.addNode(newNode, false);
                } else {
                  controller.addNode(newNode);
                }
              },
              onWillAccept: (node) {
                if (node == null) return false;
                if (controller.nodes.any((element) => element.id == node.id)) {
                  return false;
                } else {
                  return true;
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    var ctrl = widget.controller;
    if (ctrl != null) {
      ctrl.dispose();
      Get.delete<FloatingNodeController>(tag: hRulerId(ctrl.id));
      Get.delete<FloatingNodeController>(tag: vRulerId(ctrl.id));
    }
    super.dispose();
  }
}
