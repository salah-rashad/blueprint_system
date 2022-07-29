import 'package:blueprint_system/blueprint.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node.dart';
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
          initPosition: const Offset(200, 400),
          initSize: const Size(200, 100),
          child: (c) => NodeContainer(
            color: Colors.blue,
            controller: c,
          ),
          priority: 50,
          sizeFixed: false,
        ),
      ],
    );
  }
}
