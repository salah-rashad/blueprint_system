import 'package:flutter/material.dart';

/// Represents a connection between two nodes via their ports.
class Connection {
  final String id;
  final String sourceNodeId;
  final String sourcePortId;
  final String targetNodeId;
  final String targetPortId;
  final Color color;
  final double strokeWidth;

  const Connection({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  Connection copyWith({
    String? id,
    String? sourceNodeId,
    String? sourcePortId,
    String? targetNodeId,
    String? targetPortId,
    Color? color,
    double? strokeWidth,
  }) {
    return Connection(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      sourcePortId: sourcePortId ?? this.sourcePortId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      targetPortId: targetPortId ?? this.targetPortId,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceNodeId': sourceNodeId,
        'sourcePortId': sourcePortId,
        'targetNodeId': targetNodeId,
        'targetPortId': targetPortId,
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
      };

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json['id'] as String,
        sourceNodeId: json['sourceNodeId'] as String,
        sourcePortId: json['sourcePortId'] as String,
        targetNodeId: json['targetNodeId'] as String,
        targetPortId: json['targetPortId'] as String,
        color: Color(json['color'] as int),
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      );
}
