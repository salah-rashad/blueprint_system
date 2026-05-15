import 'package:flutter/material.dart';

class Out<T extends Object> extends Draggable<T> {
  const Out({
    super.key,
    required super.child,
    required super.feedback,
    super.childWhenDragging,
    super.onDragStarted,
    super.onDragUpdate,
    super.onDragEnd,
    super.onDragCompleted,
    super.onDraggableCanceled,
  });

  @override
  bool get rootOverlay => true;
}
