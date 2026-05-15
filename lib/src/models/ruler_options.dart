import 'package:flutter/material.dart';

class RulerOptions {
  final Color? textColor;
  final double interval;
  final int divisions;
  final bool hideZero;

  const RulerOptions({
    this.textColor,
    this.interval = 100.0,
    this.divisions = 1,
    this.hideZero = true,
  }) : assert(
          divisions > 0,
          'The "divisions" property must be greater than zero. If there were no divisions, the grid paper would not paint anything.',
        );

  Map<String, dynamic> toJson() => {
        'textColor': textColor?.toARGB32(),
        'interval': interval,
        'divisions': divisions,
        'hideZero': hideZero,
      };

  factory RulerOptions.fromJson(Map<String, dynamic> json) {
    return RulerOptions(
      textColor:
          json['textColor'] != null ? Color(json['textColor'] as int) : null,
      interval: (json['interval'] as num?)?.toDouble() ?? 100.0,
      divisions: json['divisions'] as int? ?? 1,
      hideZero: json['hideZero'] as bool? ?? true,
    );
  }
}
