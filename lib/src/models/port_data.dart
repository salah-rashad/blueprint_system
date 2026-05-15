import 'package:flutter/material.dart';

/// Defines a connection point on a node.
class PortData {
  final String id;
  final String label;
  final Offset relativePosition;
  final PortType type;

  const PortData({
    required this.id,
    this.label = '',
    required this.relativePosition,
    this.type = PortType.input,
  });

  PortData copyWith({
    String? id,
    String? label,
    Offset? relativePosition,
    PortType? type,
  }) {
    return PortData(
      id: id ?? this.id,
      label: label ?? this.label,
      relativePosition: relativePosition ?? this.relativePosition,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'relativePositionX': relativePosition.dx,
        'relativePositionY': relativePosition.dy,
        'type': type.name,
      };

  factory PortData.fromJson(Map<String, dynamic> json) => PortData(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        relativePosition: Offset(
          (json['relativePositionX'] as num).toDouble(),
          (json['relativePositionY'] as num).toDouble(),
        ),
        type: PortType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PortType.input,
        ),
      );
}

enum PortType { input, output }
