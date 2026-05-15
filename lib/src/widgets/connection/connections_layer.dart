import 'dart:math' show cos, sin;

import 'package:blueprint_system/src/models/connection.dart';
import 'package:flutter/material.dart';

import '../../blueprint_controller.dart';
import '../node/node_controller.dart';

/// Renders all connections between nodes as bezier curves.
class ConnectionsLayer extends StatelessWidget {
  final BlueprintController blueprint;

  const ConnectionsLayer({super.key, required this.blueprint});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ConnectionPainter(
            controller: blueprint,
          ),
        ),
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final BlueprintController controller;

  ConnectionPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final connections = controller.connections;
    if (connections.isEmpty) return;

    final scale = controller.scale;
    final cameraPos = controller.cameraPosition;

    for (final connection in connections) {
      final sourceNodeCtrl = _findNodeController(connection.sourceNodeId);
      final targetNodeCtrl = _findNodeController(connection.targetNodeId);

      if (sourceNodeCtrl == null || targetNodeCtrl == null) continue;

      final sourcePort = sourceNodeCtrl.ports
          .where((p) => p.id == connection.sourcePortId)
          .isEmpty
          ? null
          : sourceNodeCtrl.ports
              .where((p) => p.id == connection.sourcePortId)
              .first;
      final targetPort = targetNodeCtrl.ports
          .where((p) => p.id == connection.targetPortId)
          .isEmpty
          ? null
          : targetNodeCtrl.ports
              .where((p) => p.id == connection.targetPortId)
              .first;

      if (sourcePort == null || targetPort == null) continue;

      final startRaw = sourceNodeCtrl.getPortPosition(sourcePort);
      final endRaw = targetNodeCtrl.getPortPosition(targetPort);

      // Adjust for camera and scale
      final start = (startRaw * scale) - cameraPos;
      final end = (endRaw * scale) - cameraPos;

      _drawBezierConnection(canvas, start, end, connection);
    }
  }

  void _drawBezierConnection(
      Canvas canvas, Offset start, Offset end, Connection connection) {
    final paint = Paint()
      ..color = connection.color
      ..strokeWidth = connection.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final distance = (end - start).dx.abs();
    final controlPointOffset = distance.clamp(50.0, 200.0);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + controlPointOffset,
        start.dy,
        end.dx - controlPointOffset,
        end.dy,
        end.dx,
        end.dy,
      );

    canvas.drawPath(path, paint);

    // Draw arrow at the end
    _drawArrow(canvas, path, paint);
  }

  void _drawArrow(Canvas canvas, Path path, Paint paint) {
    final pathMetric = path.computeMetrics().first;
    final tangent = pathMetric.getTangentForOffset(pathMetric.length);
    if (tangent == null) return;

    final arrowPos = tangent.position;
    final arrowDir = tangent.vector;

    const arrowLength = 10.0;
    const arrowAngle = 0.5;

    final arrowPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(arrowPos.dx, arrowPos.dy)
      ..lineTo(
        arrowPos.dx - arrowDir.dx * arrowLength * cos(arrowAngle) +
            arrowDir.dy * arrowLength * sin(arrowAngle),
        arrowPos.dy - arrowDir.dy * arrowLength * cos(arrowAngle) -
            arrowDir.dx * arrowLength * sin(arrowAngle),
      )
      ..lineTo(
        arrowPos.dx - arrowDir.dx * arrowLength * cos(arrowAngle) -
            arrowDir.dy * arrowLength * sin(arrowAngle),
        arrowPos.dy - arrowDir.dy * arrowLength * cos(arrowAngle) +
            arrowDir.dx * arrowLength * sin(arrowAngle),
      )
      ..close();

    canvas.drawPath(path2, arrowPaint);
  }

  NodeController? _findNodeController(String nodeId) {
    for (final node in controller.nodes) {
      if (node.id == nodeId) return node.controller;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return true;
  }
}
