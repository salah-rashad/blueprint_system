import 'package:flutter/material.dart';

class In<T extends Object> extends DragTarget<T> {
  const In({
    super.key,
    required super.builder,
    super.onWillAccept,
    super.onAccept,
    super.onAcceptWithDetails,
    super.onLeave,
    super.onMove,
  });
}
