import 'package:flutter/material.dart';

import 'package:blueprint_system/blueprint_system.dart';

class NodeOptions<T extends NodeController> {
  const NodeOptions({
    this.id,
    this.initPosition = const Offset(100, 100),
    this.initSize = const Size(200, 200),
    this.blueprintController,
    this.priority = 1,
    this.minSize = const Size(100, 100),
    this.clipBehavior,
    this.focusEnabled = true,
  });

  /// Unique id for the node controller, it's optional to assign it
  /// and it's auto generated if not assigned in the constructor.
  final String? id;
  final BlueprintController? blueprintController;

  final Offset initPosition;
  final Size initSize;
  final int priority;
  final Size minSize;
  final Clip? clipBehavior;
  final bool focusEnabled;

  NodeOptions<T> copyWith({
    String? id,
    Offset? initPosition,
    Size? initSize,
    BlueprintController? blueprintController,
    int? priority,
    Size? minSize,
    Clip? clipBehavior,
    bool? focusEnabled,
  }) {
    return NodeOptions<T>(
      id: id ?? this.id,
      initPosition: initPosition ?? this.initPosition,
      initSize: initSize ?? this.initSize,
      blueprintController: blueprintController ?? this.blueprintController,
      priority: priority ?? this.priority,
      minSize: minSize ?? this.minSize,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      focusEnabled: focusEnabled ?? this.focusEnabled,
    );
  }
}
