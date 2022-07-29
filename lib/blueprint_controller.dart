import 'dart:math';

import 'package:blueprint_system/src/event.dart';
import 'package:blueprint_system/src/extensions.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node.dart';
import 'package:blueprint_system/widgets/floating_node/floating_node_controller.dart';
import 'package:blueprint_system/widgets/node/node.dart';
import 'package:blueprint_system/widgets/node/node_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Node;
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

class BlueprintController extends FullLifeCycleController
    with GetTickerProviderStateMixin {
  BlueprintController._(this.id);

  Size minSize = Size.zero;
  Size maxSize = Size.infinite;
  bool followNewAddedNodes = true;

  final String id;
  static BlueprintController get instance {
    var id = " // ${const Uuid().v4()}";
    BlueprintController newInstance =
        Get.put(BlueprintController._(id), tag: id);
    return newInstance;
  }

  Event<ScaleStartDetails> onInteractionStart = Event();
  Event<ScaleEndDetails> onInteractionEnd = Event();
  Event<ScaleUpdateDetails> onInteractionUpdate = Event();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool snapToGrid = false;

  Rxn<NodeController> focusedNode = Rxn();
  // BoxConstraints boxConstraints = const BoxConstraints();

  final GlobalKey _widgetKey = GlobalKey();
  GlobalKey get widgetKey => _widgetKey;

  final GlobalKey _stackKey = GlobalKey();
  GlobalKey get stackKey => _stackKey;

  final RxList<Node> _nodes = RxList.empty(growable: true);
  List<Node> get nodes => _nodes;

  Vector3 get translation => transformationController.value.getTranslation();
  Offset get cameraPosition => Offset(translation.x.abs(), translation.y.abs());

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final RxDouble _scale = RxDouble(1);
  double get scale => _scale.value;

  final Rx<Size> _size = Rx<Size>(Size.zero);
  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  final RxBool _showGrid = RxBool(true);
  bool get showGrid => _showGrid.value;
  set showGrid(bool value) => _showGrid.value = value;

  Rect? get widgetRect => widgetKey.globalPaintBounds;
  Rect? get getRect => stackKey.globalPaintBounds;

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
    size = widgetRect!.size;

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void> addNode(Node node, [bool? follow]) async {
    String id = " // ${const Uuid().v4()}";

    var newNode = node.copyWith(id: node.id ?? id, blueprintController: this);
    Get.put(newNode.init, tag: id);
    nodes.add(newNode);

    await 0.1.delay();
    updateCanvasSize();
    if (follow ?? followNewAddedNodes && node is! FloatingNode) {
      animateTo(newNode.controller);
    }
  }

  void addNodes(Iterable<Node> newNodes) {
    for (var node in newNodes) {
      addNode(node);
    }
  }

  void updateCanvasSize() {
    double w = 0;
    double h = 0;

    for (var node in _nodes) {
      var ctrl = node.controller;

      if (ctrl is FloatingNodeController) continue;

      // get bottom right edge position of this node
      Offset bottomRightEdge =
          ctrl.position + Offset(ctrl.size.width, ctrl.size.height);

      w = max(w, bottomRightEdge.dx);
      h = max(h, bottomRightEdge.dy);
    }

    w = max(w + widgetRect!.width / 2, widgetRect!.width);
    h = max(h + widgetRect!.height / 2, widgetRect!.height);

    // apply minSize & maxSize
    w = max(minSize.width, min(w, maxSize.width));
    h = max(minSize.height, min(h, maxSize.height));

    size = Size(w, h);
  }

  void animateTo(NodeController node) {
    focusedNode.value = node;

    Offset nodePos = node.position;
    Size nodeSize = node.size;

    Size widgetSize = Size(
      min(widgetRect!.width, Get.width),
      min(widgetRect!.height, Get.height),
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

  @override
  Future<void> didChangeMetrics() async {
    // await for widget to initialize, then update size.
    await 0.1.delay();
    updateCanvasSize();

    var last = focusedNode.value;
    if (last != null) {
      animateTo(last);
    }
  }
}
