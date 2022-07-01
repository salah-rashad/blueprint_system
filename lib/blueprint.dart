library blueprint_system;

import 'package:blueprint_system/blueprint_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;

class Blueprint extends StatefulWidget {
  const Blueprint(
    this.controller, {
    super.key,
  });

  final BlueprintController controller;

  @override
  State<Blueprint> createState() => _BlueprintState();
}

class _BlueprintState extends State<Blueprint> with WidgetsBindingObserver {
  late BlueprintController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller /* ?? BlueprintController() */;

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeMetrics() async {
    await 0.1.delay();
    controller.updateCanvasSize();
    var last = controller.lastDraggedNode.value;
    if (last != null) {
      controller.animateTo(last);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetX<BlueprintController>(
        init: controller,
        autoRemove: false,
        builder: (controller) {
          return Container(
            color: Colors.grey.shade900,
            key: controller.widgetKey,
            child: InteractiveViewer(
              transformationController: controller.transformationController,
              clipBehavior: Clip.antiAlias,
              onInteractionStart: controller.onInteractionStart,
              minScale: 0.1,
              maxScale: 1.0,
              // boundaryMargin: const EdgeInsets.all(32),
              constrained: false,
              child: Container(
                color: Colors.grey.shade900,
                width: controller.size.width,
                height: controller.size.height,
                child: Stack(
                  key: controller.stackKey,
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: controller.showGrid ? 1.0 : 0.0,
                        duration: 200.milliseconds,
                        child: GridPaper(
                          color: Colors.white.withOpacity(0.1),
                          divisions: 2,
                          interval: 100,
                        ),
                      ),
                    ),
                    ...controller.nodes
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
