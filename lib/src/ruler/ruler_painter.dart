import 'package:blueprint_system/src/extensions.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class RulerPainter extends CustomPainter {
  const RulerPainter({
    required this.controller,
    required this.textColor,
    required this.interval,
    required this.divisions,
    required this.axis,
    required this.hideZero,
    super.repaint,
  });

  final FloatingNodeController controller;
  final Color? textColor;
  final double interval;
  final int divisions;

  final Axis axis;
  final bool hideZero;

  @override
  void paint(Canvas canvas, Size size) {
    var scale = controller.blueprint!.scale;
    var showGrid = controller.blueprint!.showGrid;
    var cameraPosition = controller.blueprint!.cameraPosition;

    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 0.3;

    if (axis == Axis.horizontal) {
      for (double x = 0; x <= size.width; x += interval / divisions) {
        var position = Offset(x * scale, 0);

        int interval = getDynamicInterval(scale);
        if ((x % interval) != 0) continue;

        double roundX =
            (cameraPosition.dx / scale).roundBy(interval).toDouble();
        if (x <= roundX) continue;

        if (scale <= 0.5 && showGrid) {
          canvas.drawLine(
              position, Offset(position.dx, size.height), linePaint);
        }

        paintText(canvas, size, formatNumber(x), position);
      }
    } else {
      for (double y = 0; y <= size.height; y += interval / divisions) {
        var position = Offset(0, y * scale);

        int interval = getDynamicInterval(scale);
        if ((y % interval) != 0) continue;

        double roundY =
            (cameraPosition.dy / scale).roundBy(interval).toDouble();
        if (y <= roundY) continue;

        if (scale <= 0.5 && showGrid) {
          canvas.drawLine(position, Offset(size.width, position.dy), linePaint);
        }

        paintText(canvas, size, formatNumber(y), position);
      }
    }
  }

  int getDynamicInterval(double scale) {
    // if (scale <= 0.5 && scale > 0.25 && (v % 200) != 0) {
    //   return true;
    // } else if (scale <= 0.25 && scale > 0.125 && (v % 500) != 0) {
    //   return true;
    // } else if (scale <= 0.125 && (v % 1000) != 0) {
    //   return true;
    // }
    // return false;
    if (scale <= 0.5 && scale > 0.25) {
      return 200;
    } else if (scale <= 0.25 && scale > 0.125) {
      return 500;
    } else if (scale <= 0.125) {
      return 1000;
    } else {
      return 100;
    }
  }

  String formatNumber(num number) {
    var f = intl.NumberFormat("###,###", "en_US");
    return f.format(number);
  }

  @override
  bool shouldRepaint(RulerPainter oldDelegate) {
    return oldDelegate.textColor != textColor ||
        oldDelegate.interval != interval ||
        oldDelegate.divisions != divisions;
  }

  @override
  bool hitTest(Offset position) => false;

  void paintText(Canvas canvas, Size size, String text, Offset offset) {
    var textStyle = TextStyle(
      color: textColor ?? Colors.white30,
      fontSize: 14,
    );

    var textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    // final xCenter = (size.width - textPainter.width) / 2;
    // final yCenter = (size.height - textPainter.height) / 2;
    // final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }
}
