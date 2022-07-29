import 'package:blueprint_system/blueprint.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node_controller.dart';
import 'package:example/pages/state.dart';
import 'package:example/widgets/node_container.dart';
import 'package:flutter/material.dart';

class FloatingNodeExample extends StatefulWidget {
  const FloatingNodeExample({super.key});

  @override
  State<FloatingNodeExample> createState() => _FloatingNodeExampleState();
}

class _FloatingNodeExampleState extends StateClass<FloatingNodeExample> {
  _FloatingNodeExampleState() : super("Floating Node");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget child(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Blueprint(
      controller: controller,
      minSize: size * 2,
      children: [
        FloatingNode(
          initPosition: const Offset(100, 100),
          initSize: const Size(400, 300),
          child: (c) => const Text(
            """
This node will stick to the screen and will not change in interaction with the Blueprint unless you add some modifications to its properties.
For example these rulers on each Blueprint are also basically a FloatingNode, with some modifications they have become like this.
Fabulous isn't it! ✨

Try to move through the Blueprint or zoom in/out.
          """,
            // textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(100, 500),
          initSize: const Size(200, 200),
          child: (c) => const Text(
            """
This node will stay at the predetermined position (relative to screen) but it's size will change in response to the blueprint's scale.

[changes]
sizeFixed: false
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(100, 700),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade100,
            controller: c,
            text: c.constraint.toString(),
          ),
          sizeFixed: false,
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(600, 100),
          initSize: const Size(200, 200),
          child: (c) => const Text(
            """
This node will constraint the [x] coordinate of the position but the [y] coordinate will change in interaction with the Blueprint.

[changes]
constraint: Constraint.X
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(600, 300),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade200,
            controller: c,
            text: c.constraint.toString(),
          ),
          constraint: Constraint.X,
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(900, 100),
          initSize: const Size(200, 200),
          child: (c) => const Text(
            """
This node will constraint the [x & y] coordinates of the position but it's size WILL NOT scale in response to the blueprint's scale.

[changes]
constraint: Constraint.XY
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(900, 300),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade300,
            controller: c,
            text: c.constraint.toString(),
          ),
          constraint: Constraint.XY,
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(1200, 100),
          initSize: const Size(200, 200),
          child: (c) => const Text(
            """
This node will constraint the [y] coordinate of the position but the [x] coordinate will change in interaction with the Blueprint.

[changes]
constraint: Constraint.Y
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(1200, 300),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade400,
            controller: c,
            text: c.constraint.toString(),
          ),
          constraint: Constraint.Y,
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(600, 500),
          initSize: const Size(250, 200),
          child: (c) => const Text(
            """
This node will constraint the [x] coordinate (relative to the screen) but the [y] coordinate will change in response to the blueprint's scale.

[changes]
constraint: Constraint.XScreen
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(600, 700),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade700,
            controller: c,
            text: c.constraint.toString(),
          ),
          constraint: Constraint.XScreen,
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(900, 500),
          initSize: const Size(250, 200),
          child: (c) => const Text(
            """
This node will constraint the [x & y] coordinate (relative to the screen) but it's size WILL NOT scale in response to the blueprint's scale.

[changes]
constraint: Constraint.XYScreen
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(900, 700),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade800,
            controller: c,
            text: c.constraint.toString(),
          ),
          constraint: Constraint.XYScreen,
        ),
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
        FloatingNode(
          initPosition: const Offset(1200, 500),
          initSize: const Size(250, 200),
          child: (c) => const Text(
            """
This node will constraint the [y] coordinate (relative to the screen) but the [x] coordinate will change in response to the blueprint's scale.

[changes]
constraint: Constraint.YScreen
""",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        FloatingNode(
          initPosition: const Offset(1200, 700),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue.shade900,
            controller: c,
            text: c.constraint.toString(),
          ),
          constraint: Constraint.YScreen,
        ),
      ],
    );
  }
}
