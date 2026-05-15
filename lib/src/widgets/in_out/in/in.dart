import 'package:flutter/material.dart';

/// A drop target widget that accepts draggable items.
class In<T extends Object> extends DragTarget<T> {
  const In({
    super.key,
    required super.builder,
    super.onWillAcceptWithDetails,
    super.onAcceptWithDetails,
    super.onLeave,
    super.onMove,
  });
}
