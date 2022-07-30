import 'package:blueprint_system/src/blueprint_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

import 'node_controller.dart';

typedef NodeWidget<S extends NodeController> = Widget Function(S c);

abstract class Node<T extends NodeController> extends GetWidget<T> {
  const Node({
    super.key,
    this.id,
    this.child,
    this.initPosition = const Offset(100, 100),
    this.initSize = const Size(100, 100),
    this.blueprintController,
    this.priority = 1,
  });

  /// Unique id for the node controller, it's optional to assign it 
  /// and it's auto generated if not assigned in the constructor.
  final String? id;

  /// This is the child widget in the node
  final NodeWidget<T>? child;
  final Offset initPosition;
  final Size initSize;
  final BlueprintController? blueprintController;
  final int priority;

  @protected
  @override
  String? get tag => id;

  @mustCallSuper
  Widget builder(T controller) {
    return child?.call(controller) ?? const SizedBox.shrink();
  }

  T? get init;

  Node copyWith({
    String? id,
    NodeWidget<T>? child,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprintController,
    int? priority,
  });

  @nonVirtual
  @override
  T get controller =>
      init != null ? Get.put<T>(init!, tag: id) : super.controller;

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Positioned(
          left: controller.position.dx,
          top: controller.position.dy,
          width: controller.size.width,
          height: controller.size.height,
          child: builder(controller),
        );
      },
    );
  }

  Future<void> dispose() async {
    await Get.delete<T>(tag: id);
  }

  void remove() {
    blueprintController!.nodes.remove(this);
    blueprintController!.updateCanvasSize();
    if (blueprintController!.nodes.isNotEmpty) {
      blueprintController!
          .animateTo(blueprintController!.nodes.last.controller);
    }
  }
}
