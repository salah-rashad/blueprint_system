// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

import 'node_controller.dart';

typedef NodeWidget<S extends NodeController> = Widget Function(S);

abstract class Node<T extends NodeController> extends GetWidget<T> {
  Node({
    super.key,
    this.initPosition = const Offset(100, 100),
    this.initSize = const Size(100, 100),
    required this.child,
  });

  late final String id;
  final NodeWidget<T> child;
  final Offset initPosition;
  final Size initSize;

  @override
  String? get tag => id;

  Widget builder(T controller);

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
}
