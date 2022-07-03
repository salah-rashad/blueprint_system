import 'dart:math';

import 'package:blueprint_system/src/extensions.dart';
import 'package:blueprint_system/widgets/node/node_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DraggableNodeController extends NodeController {
  DraggableNodeController(super.initPosition, super.initSize);

  VoidCallback? onDragStartedCallback;
  void Function(DragUpdateDetails)? onDragUpdateCallback;
  void Function(DraggableDetails)? onDragEndCallback;

  final RxBool _isBeingDragged = RxBool(false);
  bool get isBeingDragged => _isBeingDragged.value;
  set isBeingDragged(bool value) => _isBeingDragged.value = value;

  final Rx<Offset> _dragAnchor = Rx<Offset>(Offset.zero);
  Offset get dragAnchor => _dragAnchor.value;
  set dragAnchor(Offset value) => _dragAnchor.value = value;

  Offset dragAnchorStrategy(
          Draggable<Object> draggable, BuildContext context, Offset position) =>
      dragAnchor * blueprint.scale;

  void onDragStarted() {
    onDragStartedCallback?.call();
    isBeingDragged = true;
  }

  void onDragUpdate(DragUpdateDetails details) {
    onDragUpdateCallback?.call(details);
  }

  void onDragEnd(DraggableDetails details) {
    onDragEndCallback?.call(details);
    isBeingDragged = false;

    final blueprintRect = blueprint.getRect;
    if (blueprintRect == null) return;

    double x = (details.offset.dx - blueprintRect.left) / blueprint.scale;
    double y = (details.offset.dy - blueprintRect.top) / blueprint.scale;

    x = max(0, x);
    y = max(0, y);

    if (blueprint.snapToGrid) {
      x = x.roundTens().toDouble();
      y = y.roundTens().toDouble();
    }

    position = Offset(x, y);

    blueprint.updateCanvasSize();
    blueprint.animateTo(this);
  }
}
