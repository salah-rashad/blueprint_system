import 'package:blueprint_system/widgets/node/node.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

import 'fixed_node_controller.dart';

class FixedNode extends Node<FixedNodeController> {
  FixedNode({
    super.key,
    required super.child,
    super.initPosition,
    super.initSize,
  });

  @override
  FixedNodeController get controller =>
      Get.put(FixedNodeController(initPosition, initSize), tag: id);

  @override
  Widget builder(FixedNodeController controller) {
    return child(controller);
  }
}
