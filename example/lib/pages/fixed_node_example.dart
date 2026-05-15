import 'package:blueprint_system/blueprint_system.dart';
import 'package:example/pages/state.dart';
import 'package:example/widgets/node_container.dart';
import 'package:flutter/material.dart';

class FixedNodeExample extends StatefulWidget {
  const FixedNodeExample({super.key});

  @override
  State<FixedNodeExample> createState() => _FixedNodeExampleState();
}

class _FixedNodeExampleState extends StateClass<FixedNodeExample> {
  _FixedNodeExampleState() : super("Fixed Node");

  @override
  Widget child(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Blueprint(
      controller: controller,
      minSize: size * 2,
      followNewAddedNodes: false,
      children: [
        FixedNode(
          initPosition: const Offset(100, 100),
          initSize: const Size(600, 100),
          priority: 0,
          child: (c) => const Text(
            """
FixedNode is very simple, this node will remain in its predetermined position and cannot be moved.
Try to explore the blueprint or zoom out ;)
          """,
            // textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FixedNode(
          initPosition: const Offset(100, 300),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.red,
            controller: c,
          ),
        ),
        FixedNode(
          initPosition: const Offset(500, 1000),
          initSize: const Size(500, 300),
          child: (c) => NodeContainer(
            color: Colors.red,
            controller: c,
          ),
        ),
        shape(2500, 2500),
        shape(2500, 2600),
        shape(2500, 2700),
        shape(2500, 2800),
        shape(2500, 2900),
        shape(2600, 2700),
        shape(2700, 2500),
        shape(2700, 2600),
        shape(2700, 2700),
        shape(2700, 2800),
        shape(2700, 2900),
        shape(2900, 2500),
        shape(2900, 2700),
        shape(2900, 2800),
        shape(2900, 2900),
      ],
    );
  }

  FixedNode shape(double x, double y) {
    return FixedNode(
      initPosition: Offset(x, y),
      initSize: const Size(100, 100),
      child: (c) => NodeContainer(
        color: Colors.red,
        controller: c,
      ),
      priority: 50,
    );
  }
}
