import 'package:blueprint_system/blueprint.dart';
import 'package:blueprint_system/widgets/draggable_node/draggable_node.dart';
import 'package:example/pages/state.dart';
import 'package:example/widgets/node_container.dart';
import 'package:flutter/material.dart';

class DraggableNodeExample extends StatefulWidget {
  const DraggableNodeExample({super.key});

  @override
  State<DraggableNodeExample> createState() => _DraggableNodeExampleState();
}

class _DraggableNodeExampleState extends StateClass<DraggableNodeExample> {
  _DraggableNodeExampleState() : super("Draggable Node");

  @override
  Widget child(BuildContext context) {
    return Blueprint(
      controller: controller,
      followNewAddedNodes: false,
      children: [
        DraggableNode(
          initPosition: const Offset(100, 100),
          initSize: const Size(600, 100),
          priority: 0,
          child: (c) => const Text(
            """
The DraggableNode can be moved anywhere in the Blueprint, 
and in this example we show how the nodes are arranged in order of priority.
Try to move any ;)
          """,
            // textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        DraggableNode(
          initPosition: const Offset(250, 350),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.green,
            controller: c,
          ),
          priority: 50,
        ),
        DraggableNode(
          initPosition: const Offset(200, 430),
          initSize: const Size(200, 350),
          child: (c) => NodeContainer(
            color: Colors.greenAccent,
            controller: c,
          ),
          priority: 200,
        ),
        DraggableNode(
          initPosition: const Offset(100, 300),
          initSize: const Size(200, 200),
          child: (c) => NodeContainer(
            color: Colors.lightGreen,
            controller: c,
          ),
        ),
      ],
    );
  }
}
