import 'package:flutter/material.dart';

class BlueprintTheme {
  /// Canvas background color.
  final Color backgroundColor;
  final Color gridColor;
  final Color gridLineColor;

  /// Port colors
  final Color defaultPortInputColor;
  final Color defaultPortOutputColor;

  /// Connection colors
  final Color defaultConnectionColor;
  final double defaultConnectionStrokeWidth;

  /// Ruler colors
  final Color rulerTextColor;
  final Color rulerLineColor;

  /// Size handle color
  final Color sizeHandleColor;

  const BlueprintTheme({
    required this.backgroundColor,
    required this.gridColor,
    required this.gridLineColor,
    required this.defaultPortInputColor,
    required this.defaultPortOutputColor,
    required this.defaultConnectionColor,
    this.defaultConnectionStrokeWidth = 2.0,
    required this.rulerTextColor,
    required this.rulerLineColor,
    required this.sizeHandleColor,
  });

  /// A dark theme (matches the current hardcoded defaults).
  factory BlueprintTheme.dark() => const BlueprintTheme(
        backgroundColor: Color(0xFF212121),
        gridColor: Color(0x1AFFFFFF),
        gridLineColor: Color(0x1AFFFFFF),
        defaultPortInputColor: Colors.orange,
        defaultPortOutputColor: Colors.green,
        defaultConnectionColor: Colors.white,
        rulerTextColor: Color(0x4DFFFFFF),
        rulerLineColor: Color(0x33FFFFFF),
        sizeHandleColor: Colors.white,
      );

  /// A light theme.
  factory BlueprintTheme.light() => const BlueprintTheme(
        backgroundColor: Color(0xFFFAFAFA),
        gridColor: Color(0x1A000000),
        gridLineColor: Color(0x1A000000),
        defaultPortInputColor: Colors.orange,
        defaultPortOutputColor: Colors.green,
        defaultConnectionColor: Colors.black,
        rulerTextColor: Color(0x4D000000),
        rulerLineColor: Color(0x33000000),
        sizeHandleColor: Colors.black87,
      );

  BlueprintTheme copyWith({
    Color? backgroundColor,
    Color? gridColor,
    Color? gridLineColor,
    Color? defaultPortInputColor,
    Color? defaultPortOutputColor,
    Color? defaultConnectionColor,
    double? defaultConnectionStrokeWidth,
    Color? rulerTextColor,
    Color? rulerLineColor,
    Color? sizeHandleColor,
  }) {
    return BlueprintTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridColor: gridColor ?? this.gridColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      defaultPortInputColor:
          defaultPortInputColor ?? this.defaultPortInputColor,
      defaultPortOutputColor:
          defaultPortOutputColor ?? this.defaultPortOutputColor,
      defaultConnectionColor:
          defaultConnectionColor ?? this.defaultConnectionColor,
      defaultConnectionStrokeWidth:
          defaultConnectionStrokeWidth ?? this.defaultConnectionStrokeWidth,
      rulerTextColor: rulerTextColor ?? this.rulerTextColor,
      rulerLineColor: rulerLineColor ?? this.rulerLineColor,
      sizeHandleColor: sizeHandleColor ?? this.sizeHandleColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'backgroundColor': backgroundColor.toARGB32(),
        'gridColor': gridColor.toARGB32(),
        'gridLineColor': gridLineColor.toARGB32(),
        'defaultPortInputColor': defaultPortInputColor.toARGB32(),
        'defaultPortOutputColor': defaultPortOutputColor.toARGB32(),
        'defaultConnectionColor': defaultConnectionColor.toARGB32(),
        'defaultConnectionStrokeWidth': defaultConnectionStrokeWidth,
        'rulerTextColor': rulerTextColor.toARGB32(),
        'rulerLineColor': rulerLineColor.toARGB32(),
        'sizeHandleColor': sizeHandleColor.toARGB32(),
      };

  factory BlueprintTheme.fromJson(Map<String, dynamic> json) {
    return BlueprintTheme(
      backgroundColor: Color(json['backgroundColor'] as int),
      gridColor: Color(json['gridColor'] as int),
      gridLineColor: Color(json['gridLineColor'] as int),
      defaultPortInputColor: Color(json['defaultPortInputColor'] as int),
      defaultPortOutputColor: Color(json['defaultPortOutputColor'] as int),
      defaultConnectionColor: Color(json['defaultConnectionColor'] as int),
      defaultConnectionStrokeWidth:
          (json['defaultConnectionStrokeWidth'] as num?)?.toDouble() ?? 2.0,
      rulerTextColor: Color(json['rulerTextColor'] as int),
      rulerLineColor: Color(json['rulerLineColor'] as int),
      sizeHandleColor: Color(json['sizeHandleColor'] as int),
    );
  }
}
