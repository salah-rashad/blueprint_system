import 'package:blueprint_system/src/models/connection.dart';
import 'package:blueprint_system/src/models/port_data.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../node/node_controller.dart';

/// Carries both port and node info during drag operations.
class _PortDragData {
  final NodeController node;
  final PortData port;
  const _PortDragData(this.node, this.port);
}

/// A small draggable port that appears on nodes for creating connections.
class PortWidget extends StatelessWidget {
  final NodeController nodeController;
  final PortData port;
  final double radius;

  const PortWidget({
    super.key,
    required this.nodeController,
    required this.port,
    this.radius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final isOutput = port.type == PortType.output;
    final theme = nodeController.blueprint?.theme;
    final color = isOutput
        ? (theme?.defaultPortOutputColor ?? Colors.green)
        : (theme?.defaultPortInputColor ?? Colors.orange);

    // Input ports accept drags; output ports initiate drags.
    // If this is an input port, wrap in DragTarget.
    Widget circle = _buildPortCircle(color: color, radius: radius);

    if (!isOutput) {
      circle = DragTarget<_PortDragData>(
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (data.node == nodeController) return;

          final blueprint = nodeController.blueprint;
          if (blueprint == null) return;

          final connection = Connection(
            id: const Uuid().v4(),
            sourceNodeId: data.node.id ?? '',
            sourcePortId: data.port.id,
            targetNodeId: nodeController.id ?? '',
            targetPortId: port.id,
          );

          blueprint.addConnection(connection);
        },
        onWillAcceptWithDetails: (details) {
          if (port.type != PortType.input) return false;
          if (details.data.node == nodeController) return false;
          return true;
        },
        builder: (context, candidateData, rejectedData) {
          final isAccepting = candidateData.isNotEmpty;
          return _buildPortCircle(
            color: isAccepting ? Colors.yellow : color,
            radius: radius,
            glow: isAccepting,
          );
        },
      );
    }

    return Positioned(
      left: port.relativePosition.dx - radius,
      top: port.relativePosition.dy - radius,
      child: Draggable<_PortDragData>(
        data: _PortDragData(nodeController, port),
        feedback: _buildPortCircle(
          color: color,
          radius: radius * 1.5,
          glow: true,
        ),
        childWhenDragging: isOutput ? const SizedBox.shrink() : circle,
        rootOverlay: true,
        maxSimultaneousDrags: 1,
        child: circle,
      ),
    );
  }

  Widget _buildPortCircle({
    required Color color,
    required double radius,
    bool glow = false,
  }) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}
