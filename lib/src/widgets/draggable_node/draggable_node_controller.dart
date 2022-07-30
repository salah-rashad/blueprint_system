import 'dart:io';

import 'package:blueprint_system/src/widgets/node/node_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DraggableNodeController extends NodeController {
  DraggableNodeController({
    super.id,
    required super.initPosition,
    required super.initSize,
    required super.priority,
    super.blueprint,
  });

  VoidCallback? onDragStartedCallback;
  void Function(DragUpdateDetails)? onDragUpdateCallback;
  void Function(DraggableDetails)? onDragEndCallback;

  final RxBool _isGrabbed = RxBool(false);
  bool get isGrabbed => _isGrabbed.value;
  set isGrabbed(bool value) => _isGrabbed.value = value;

  final Rx<Offset> _dragAnchor = Rx<Offset>(Offset.zero);
  Offset get dragAnchor => _dragAnchor.value;
  set dragAnchor(Offset value) => _dragAnchor.value = value;

  Offset dragAnchorStrategy(
          Draggable<Object> draggable, BuildContext context, Offset position) =>
      dragAnchor * blueprint!.scale;

  MouseCursor get mouseCursor {
    if (isGrabbed) {
      if (Platform.isWindows) {
        return SystemMouseCursors.move;
      } else {
        return SystemMouseCursors.grabbing;
      }
    } else {
      if (Platform.isWindows) {
        return SystemMouseCursors.move;
      } else {
        return SystemMouseCursors.grab;
      }
    }
  }

  void onDragStarted() {
    onDragStartedCallback?.call();
    isGrabbed = true;
  }

  void onDragUpdate(DragUpdateDetails details) {
    onDragUpdateCallback?.call(details);
  }

  Future<void> onDragEnd(DraggableDetails details) async {
    onDragEndCallback?.call(details);
    isGrabbed = false;

    var calculatedPos = NodeController.calculateOffset(details.offset, size, blueprint!);
    if (calculatedPos != null) {
      position = calculatedPos;
    }

    blueprint?.updateCanvasSize();
    blueprint?.animateTo(this);
  }
}
