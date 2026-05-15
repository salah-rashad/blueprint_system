
import 'package:blueprint_system/blueprint_system.dart';
import 'package:flutter/material.dart';

class NodeContainer extends StatelessWidget {
  const NodeContainer({
    super.key,
    required this.color,
    required this.controller,
    this.text,
  });

  final Color color;
  final NodeController controller;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          "${controller.runtimeType.toString().replaceAll("Controller", "")}\n"
          "\n"
          "X:   ${controller.position.dx.toStringAsFixed(1)}\n"
          "Y:   ${controller.position.dy.toStringAsFixed(1)}\n"
          "\n"
          "width:   ${controller.size.width} px\n"
          "height:   ${controller.size.height} px\n"
          "\n"
          "priority:   ${controller.priority}",
      textStyle: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontFeatures: [
          FontFeature.tabularFigures(),
        ],
      ),
      verticalOffset: controller.sizeScaled.height / 2,
      waitDuration: const Duration(milliseconds: 300),
      preferBelow: false,
      child: Container(
        decoration: BoxDecoration(color: color),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "X: ${controller.position.dx.toStringAsFixed(1)}\n"
              "Y: ${controller.position.dy.toStringAsFixed(1)}\n"
              "${text ?? ""}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
