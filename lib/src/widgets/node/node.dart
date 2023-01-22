import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../blueprint_controller.dart';
import '../fixed_node/fixed_node.dart';
import '../size_handle/size_handle.dart';
import 'node_controller.dart';

typedef NodeWidget<S extends NodeController> = Widget Function(S c);

abstract class Node<T extends NodeController> extends GetWidget<T> {
  const Node({
    super.key,
    this.id,
    this.initPosition = const Offset(100, 100),
    this.initSize = const Size(200, 200),
    this.child,
    this.blueprint,
    this.priority = 1,
    this.minSize = const Size(100, 100),
    this.clipBehavior,
    this.focusEnabled = true,
  });

  /// Unique id for the node controller, it's optional to assign it
  /// and it's auto generated if not assigned in the constructor.
  final String? id;

  /// This is the child widget of the node
  final NodeWidget<T>? child;
  final Offset initPosition;
  final Size initSize;
  final BlueprintController? blueprint;
  final int priority;
  final Size minSize;
  final Clip? clipBehavior;
  final bool focusEnabled;

  @protected
  @override
  String? get tag => id;

  @mustCallSuper
  Widget builder(T controller) {
    return GestureDetector(
      onTap: !focusEnabled ? null : () => blueprint?.focusedNode = controller,
      child: ClipRect(
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        child: child?.call(controller) ?? const SizedBox.shrink(),
      ),
    );
  }

  T get init;

  Node copyWith({
    String? id,
    NodeWidget<T>? child,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprint,
    int? priority,
    bool? focusEnabled,
  });

  @override
  @nonVirtual
  @override
  T get controller => Get.put<T>(init, tag: id);

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          if (controller.resizable) ...[
            SizeHandle(controller, Alignment.centerRight),
            SizeHandle(controller, Alignment.bottomCenter),
            SizeHandle(controller, Alignment.bottomRight),
            if (this is! FixedNode) ...[
              SizeHandle(controller, Alignment.topRight),
              SizeHandle(controller, Alignment.topLeft),
              SizeHandle(controller, Alignment.bottomLeft),
              SizeHandle(controller, Alignment.topCenter),
              SizeHandle(controller, Alignment.centerLeft),
            ]
          ],
          Positioned(
            left: controller.position.dx,
            top: controller.position.dy,
            child: SizedBox.fromSize(
              size: controller.size,
              child: builder(controller),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> dispose() async {
    await Get.delete<T>(tag: id);
  }

  void remove(BuildContext context) {
    blueprint?.nodes.remove(this);
    blueprint?.updateCanvasSize();

    if (blueprint?.nodes.isNotEmpty == true) {
      blueprint?.animateToLast();
    }
  }
}
