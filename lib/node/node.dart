import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'node_controller.dart';

class Node extends StatelessWidget {
  const Node(
    this.id,
    this.controller, {
    super.key,
  });

  final String id;
  final NodeController controller;

  @override
  Widget build(BuildContext context) {
    return GetX<NodeController>(
      init: controller,
      tag: id,
      builder: (controller) {
        return Positioned(
          left: controller.position.dx,
          top: controller.position.dy,
          width: controller.size.width,
          height: controller.size.height,
          child: Draggable(
            feedback: node(controller),
            childWhenDragging: const SizedBox.shrink(),
            onDragEnd: controller.onDrag,
            child: node(controller),
          ),
        );
      },
    );
  }

  Widget node(NodeController controller, [Size? s]) {
    var pos = controller.position;
    var size = s ?? controller.size * (controller.blueprint?.scale ?? 1);
    return Material(
      color: Colors.red,
      child: Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        child: Text(
            "[${pos.dx.toStringAsFixed(2)}, ${pos.dy.toStringAsFixed(2)}]"),
      ),
    );
  }
}
