import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../node/node_controller.dart';

class DraggableNodeController extends NodeController {
  DraggableNodeController({
    required super.id,
    required super.initPosition,
    required super.initSize,
    required super.priority,
    required super.minSize,
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
      return SystemMouseCursors.move;
    } else {
      return SystemMouseCursors.move;
    }
  }

  void onDragStarted() {
    onDragStartedCallback?.call();
    // blueprint?.nodeGlobalCallbacks.onNodeDragStart.invoke(position);
    isGrabbed = true;
  }

  void onDragUpdate(DragUpdateDetails details) {
    onDragUpdateCallback?.call(details);
    // blueprint?.nodeGlobalCallbacks.onNodeDragUpdate.invoke(position);
  }

  Future<void> onDragEnd(DraggableDetails details) async {
    onDragEndCallback?.call(details);
    isGrabbed = false;

    var calculatedPos =
        NodeController.calculateOffset(details.offset, size, blueprint!);
    if (calculatedPos != null) {
      blueprint?.nodeGlobalEvents.onMoved.invoke(this, position, calculatedPos);
      position = calculatedPos;
    }

    blueprint?.updateCanvasSize();
    blueprint?.animateTo(this);
  }
}
