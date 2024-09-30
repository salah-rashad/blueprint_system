// import 'package:blueprint_system/src/models/ruler_options.dart';
// import 'package:blueprint_system/src/widgets/ruler/ruler.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Node;

// import '../../blueprint_controller.dart';
// import '../floating_node/floating_node_controller.dart';
// import '../node/node.dart';
// import '../node/node_controller.dart';

// class Blueprint extends StatefulWidget {
//   static const Size maxBlueprintSize = Size(50000, 50000);

//   const Blueprint({
//     super.key,
//     this.controller,
//     List<Node>? children,
//     this.backgroundColor,
//     this.minSize,
//     this.maxSize = maxBlueprintSize,
//     this.followNewAddedNodes,
//     this.yRulerOptions = const RulerOptions(),
//     this.xRulerOptions = const RulerOptions(),
//   }) : _children = children;

//   final BlueprintController? controller;
//   final List<Node>? _children;
//   final Color? backgroundColor;
//   final Size? minSize;
//   final Size? maxSize;
//   final bool? followNewAddedNodes;

//   /// Horizontal ruler options.
//   final RulerOptions xRulerOptions;

//   /// Vertical ruler options.
//   final RulerOptions yRulerOptions;

//   @override
//   State<Blueprint> createState() => _BlueprintState();
// }

// class _BlueprintState extends State<Blueprint> {
//   String hRulerId(String blueprintId) => "/Horizontal-Ruler[$blueprintId]";
//   String vRulerId(String blueprintId) => "/Vertical-Ruler[$blueprintId]";

//   BlueprintController get controller =>
//       widget.controller ?? BlueprintController.instance;

//   @override
//   Widget build(BuildContext context) {
//     return GetX<BlueprintController>(
//       init: controller,
//       tag: widget.controller?.id,
//       autoRemove: true,
//       initState: (state) {
//         var ctrl = state.controller;
//         if (ctrl != null) {
//           ctrl.minSize = widget.minSize ?? Size.zero;
//           ctrl.maxSize = widget.maxSize ?? Size.infinite;
//           ctrl.followNewAddedNodes = widget.followNewAddedNodes ?? true;
//           ctrl.addNodes(widget._children ?? []);
//         }
//       },
//       builder: (controller) {
//         return GestureDetector(
//           onTap: () => controller.focusedNode = null,
//           child: Container(
//             color: widget.backgroundColor ?? Colors.grey.shade900,
//             key: controller.widgetKey,
//             child: InteractiveViewer(
//               transformationController: controller.transformationController,
//               clipBehavior: Clip.antiAlias,
//               onInteractionStart: (d) {
//                 controller.onInteractionStart.invoke(d);
//                 controller.onInteractionStart_(d);
//               },
//               onInteractionEnd: controller.onInteractionEnd.invoke,
//               onInteractionUpdate: (d) {
//                 controller.onInteractionUpdate.invoke(d);
//                 controller.onInteractionUpdate_(d);
//               },
//               minScale: 0.1,
//               maxScale: 1.0,
//               constrained: false,
//               child: Container(
//                 color: widget.backgroundColor ?? Colors.grey.shade900,
//                 width: controller.size.width,
//                 height: controller.size.height,
//                 child: DragTarget<Node>(
//                   builder: (context, candidateData, rejectedData) {
//                     return Stack(
//                       key: controller.stackKey,
//                       fit: StackFit.expand,
//                       children: [
//                         Positioned.fill(
//                           child: AnimatedOpacity(
//                             opacity: controller.showGrid ? 1.0 : 0.0,
//                             duration: const Duration(milliseconds: 200),
//                             child: GridPaper(
//                               color: Colors.white.withOpacity(0.1),
//                               divisions: 2,
//                               interval: 100,
//                             ),
//                           ),
//                         ),
//                         ...controller.nodes
//                           ..sort((a, b) => a.priority.compareTo(b.priority)),
//                         Ruler(
//                           // tooltip: "X direction",
//                           id: hRulerId(controller.id),
//                           axis: Axis.horizontal,
//                           blueprint: controller,
//                           options: widget.xRulerOptions,
//                         ),
//                         Ruler(
//                           // tooltip: "Y direction",
//                           id: vRulerId(controller.id),
//                           axis: Axis.vertical,
//                           blueprint: controller,
//                           options: widget.yRulerOptions,
//                         ),
//                       ],
//                     );
//                   },
//                   onAcceptWithDetails: (details) {
//                     var droppedNode = details.data;

//                     // move node from a blueprint to another
//                     if (droppedNode.blueprint != null) {
//                       // disabling this feature until this issue gets fixed
//                       // https://github.com/salah-rashad/blueprint_system/issues/2
//                       return;
//                     }

//                     var offset = NodeController.calculateOffset(
//                       details.offset,
//                       droppedNode.controller.size,
//                       controller,
//                     );
//                     var newNode = droppedNode.copyWith(initPosition: offset);

//                     controller.addNode(newNode);
//                   },
//                   onWillAcceptWithDetails: (details) {
//                     final node = details.data;
//                     // if (node == null) return false;
//                     if (controller.nodes
//                         .any((element) => element.id == node.id)) {
//                       return false;
//                     } else {
//                       return true;
//                     }
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Future<void> dispose() async {
//     var ctrl = widget.controller;
//     if (ctrl != null) {
//       await ctrl.dispose();
//       Get.delete<FloatingNodeController>(tag: hRulerId(ctrl.id));
//       Get.delete<FloatingNodeController>(tag: vRulerId(ctrl.id));
//     }
//     super.dispose();
//   }
// }
