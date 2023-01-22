import 'dart:developer' as dev;
import 'dart:math';

import 'package:blueprint_system/src/models/node_events.dart';
import 'package:blueprint_system/src/utils/event.dart';
import 'package:blueprint_system/src/utils/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Node;
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

import 'widgets/floating_node/floating_node.dart';
import 'widgets/floating_node/floating_node_controller.dart';
import 'widgets/node/node.dart';
import 'widgets/node/node_controller.dart';

class BlueprintController extends FullLifeCycleController
    with GetTickerProviderStateMixin {
  BlueprintController._(this.id);

  static BlueprintController get instance {
    var id = "/${const Uuid().v4()}";
    BlueprintController newInstance =
        Get.put(BlueprintController._(id), tag: id);
    return newInstance;
  }

  final String id;
  Size minSize = Size.zero;
  Size maxSize = Size.infinite;
  bool followNewAddedNodes = true;
  NodeEvents nodeGlobalEvents = NodeEvents();

  Event<ScaleStartDetails, void Function(ScaleStartDetails details)>
      onInteractionStart = Event();
  Event<ScaleEndDetails, void Function(ScaleEndDetails details)>
      onInteractionEnd = Event();
  Event<ScaleUpdateDetails, void Function(ScaleUpdateDetails details)>
      onInteractionUpdate = Event();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool snapToGrid = false;

  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey stackKey = GlobalKey();

  final Rxn<NodeController> _focusedNode = Rxn();
  NodeController? get focusedNode => _focusedNode.value;
  set focusedNode(NodeController? value) => _focusedNode.value = value;

  final Rx<List<Node>> _nodes = Rx(List.empty(growable: true));
  List<Node> get nodes => _nodes.value;

  Vector3 get _translation => transformationController.value.getTranslation();
  Rect? get getRect => stackKey.globalPaintBounds;

  Offset get cameraPosition =>
      Offset(_translation.x.abs(), _translation.y.abs());
  Size? get cameraSize => widgetKey.globalPaintBounds?.size;

  Size? get resolvedSize => (cameraSize! + cameraPosition) / scale;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final Rx<double> _scale = Rx(1);
  double get scale => _scale.value;

  final Rx<Size> _size = Rx<Size>(Size.zero);
  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  final Rx<bool> _showGrid = Rx(true);
  bool get showGrid => _showGrid.value;
  set showGrid(bool value) => _showGrid.value = value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var transformationController = TransformationController();

  Animation<Matrix4>? _anim;
  late final AnimationController _animController;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _scaleListener() {
    _scale.value = transformationController.value.getMaxScaleOnAxis();
  }

  @override
  void onInit() {
    super.onInit();
    transformationController.addListener(_scaleListener);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void onReady() {
    super.onReady();
    size = cameraSize!;

    transformationController.addListener(onInteractionUpdate.invoke);
    WidgetsBinding.instance.addObserver(this);
    updateCanvasSize();
  }

  @override
  void onClose() {
    _animController.dispose();
    transformationController.removeListener(_scaleListener);
    WidgetsBinding.instance.removeObserver(this);

    super.onClose();
  }

  @override
  Future<void> dispose() async {
    Get.delete<BlueprintController>(tag: id);
    for (var node in nodes) {
      await node.dispose();
    }
    super.dispose();
  }

  @override
  Future<void> didChangeMetrics() async {
    // await for widget to initialize, then update size.
    await Future.delayed(const Duration(milliseconds: 100));
    updateCanvasSize();

    var focused = focusedNode;
    if (focused != null) {
      // checks if the focused node is visible on screen or not,
      // if true, animate to it.
      Offset bottomRightEdge =
          focused.position + Offset(focused.size.width, focused.size.height);

      if (bottomRightEdge > cameraPosition) {
        animateTo(focused);
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void> addNode(Node node, [bool? follow]) async {
    String id = " // ${const Uuid().v4()}";

    var newNode = node.copyWith(id: node.id ?? id, blueprint: this);
    Get.lazyPut(() async => newNode.init, tag: node.id ?? id);
    nodes.add(newNode);

    await 0.1.delay();
    updateCanvasSize();
    if (follow ?? followNewAddedNodes && node is! FloatingNode) {
      animateTo(newNode.controller);
    }
  }

  void addNodes(Iterable<Node>? newNodes) {
    if (newNodes != null) {
      for (var node in newNodes) {
        addNode(node);
      }
    }
  }

  void updateCanvasSize() {
    // final width
    double w = 0;
    // final height
    double h = 0;

    // update size depending on every node's position and size
    for (var node in nodes) {
      var nodeCtrl = node.controller;

      if (nodeCtrl is FloatingNodeController) continue;

      // get bottom right edge position of this node
      Offset bottomRightEdge =
          nodeCtrl.position + Offset(nodeCtrl.size.width, nodeCtrl.size.height);

      w = max(w, bottomRightEdge.dx);
      h = max(h, bottomRightEdge.dy);
    }

    w = max(
      w + cameraSize!.width / 2,
      resolvedSize!.width + cameraSize!.width / scale,
    );
    h = max(
      h + cameraSize!.height / 2,
      resolvedSize!.height + cameraSize!.height / scale,
    );

    // apply minSize & maxSize
    w = max(minSize.width, min(w, maxSize.width));
    h = max(minSize.height, min(h, maxSize.height));

    size = Size(w, h);
  }

  void animateToLast() {
    if (nodes.isNotEmpty) {
      animateTo(nodes.last.controller);
    }
  }

  void animateTo(NodeController node) {
    try {
      var screenSize = MediaQuery.of(widgetKey.currentContext!).size;
      _focusedNode.value = node;

      Offset nodePos = node.position;
      Size nodeSize = node.size;

      Size widgetSize = Size(
        min(cameraSize!.width, screenSize.width),
        min(cameraSize!.height, screenSize.height),
      );

      Matrix4 scrollEnd = Matrix4.identity();

      var x = (widgetSize.width / 2) - (nodeSize.width / 2) - nodePos.dx;
      var y = (widgetSize.height / 2) - (nodeSize.height / 2) - nodePos.dy;

      Vector3 translation = Vector3(
        min(0, max(x, widgetSize.width - size.width)),
        min(0, max(y, widgetSize.height - size.height)),
        0,
      );

      scrollEnd.setTranslation(translation);

      _stopAnim();
      _anim = Matrix4Tween(
        begin: transformationController.value,
        end: scrollEnd,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _anim!.addListener(_onAnimate);
      _animController.forward();
    } catch (error, stacktrace) {
      dev.log(
        "An error occured while animating to ${node.runtimeType} [${node.id}]",
        name: "ERROR",
        error: error,
        stackTrace: stacktrace,
      );
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onAnimate() {
    transformationController.value = _anim!.value;
    if (!_animController.isAnimating) {
      _anim!.removeListener(_onAnimate);
      _anim = null;
      _animController.reset();
    }
  }

// Stop a running reset to home transform animation.
  void _stopAnim() {
    _animController.stop();
    _anim?.removeListener(_onAnimate);
    _anim = null;
    _animController.reset();
  }

  void onInteractionStart_(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_animController.status == AnimationStatus.forward) {
      _stopAnim();
    }
  }

  void onInteractionUpdate_(ScaleUpdateDetails details) {
    double trigger = 200 / scale;
    if (resolvedSize != null) {
      if (resolvedSize!.width + trigger >= size.width ||
          resolvedSize!.height + trigger >= size.height ||
          size.width - resolvedSize!.width > cameraSize!.width / scale ||
          size.height - resolvedSize!.height > cameraSize!.width / scale) {
        updateCanvasSize();
      }
    }
  }
}
