import 'dart:math';

import 'package:blueprint_system/blueprint.dart';
import 'package:blueprint_system/widgets/draggable_node/draggable_node.dart';
import 'package:blueprint_system/widgets/fixed_node/fixed_node.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node.dart';
import 'package:blueprint_system/widgets/node/node.dart';
import 'package:example/pages/state.dart';
import 'package:example/widgets/node_container.dart';
import 'package:flutter/material.dart';

class SandboxExample extends StatefulWidget {
  const SandboxExample({super.key});

  @override
  State<SandboxExample> createState() => _SandboxExampleState();
}

class _SandboxExampleState extends StateClass<SandboxExample> {
  _SandboxExampleState() : super("Sandbox");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget child(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(child: Blueprint(controller: controller)),
        Container(
          color: Colors.grey.shade700,
          width: min(size.width * 0.3, 300),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                nodeItem(
                  "Fixed Node",
                  FixedNode(
                    initSize: const Size(200, 100),
                    child: (c) => NodeContainer(
                      color: Colors.red,
                      controller: c,
                    ),
                  ),
                  Colors.red,
                ),
                const SizedBox(height: 16.0),
                nodeItem(
                  "Draggable Node",
                  DraggableNode(
                    initSize: const Size(200, 100),
                    child: (c) => NodeContainer(
                      color: Colors.green,
                      controller: c,
                    ),
                  ),
                  Colors.green,
                ),
                const SizedBox(height: 16.0),
                nodeItem(
                  "Floating Node",
                  FloatingNode(
                    initSize: const Size(100, 100),
                    child: (c) => NodeContainer(
                      color: Colors.blue,
                      controller: c,
                    ),
                  ),
                  Colors.blue,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget nodeItem(
    String text,
    Node node,
    Color color,
  ) {
    return Draggable<Node>(
      data: node,
      feedback: Material(
        type: MaterialType.transparency,
        child: Container(
          width: node.initSize.width,
          height: node.initSize.height,
          color: color,
          child: Text(text),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: Container(
        width: node.initSize.width,
        height: node.initSize.height,
        color: color,
        child: Text(text),
      ),
    );
  }
}
