import 'dart:math';

import 'package:blueprint_system/src/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Node;
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

import 'node/node.dart';
import 'node/node_controller.dart';

class BlueprintController extends GetxController
    with GetTickerProviderStateMixin {
  BlueprintController();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool snapToGrid = false;

  double scale = 1;
  Rxn<NodeController> lastDraggedNode = Rxn();
  // BoxConstraints boxConstraints = const BoxConstraints();

  final GlobalKey _widgetKey = GlobalKey();
  GlobalKey get widgetKey => _widgetKey;

  final GlobalKey _stackKey = GlobalKey();
  GlobalKey get stackKey => _stackKey;

  final RxList<Node> _nodes = RxList.empty(growable: true);

  List<Node> get nodes => _nodes;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Rx<Size> _size = Rx<Size>(Size.zero);
  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  final RxBool _showGrid = RxBool(true);
  bool get showGrid => _showGrid.value;
  set showGrid(bool value) => _showGrid.value = value;

  Rect get widgetRect => widgetKey.globalPaintBounds!;
  Rect? get getRect => stackKey.globalPaintBounds;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var transformationController = TransformationController();

  Animation<Matrix4>? _anim;
  late final AnimationController _animController;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _scaleListener() {
    scale = transformationController.value.getMaxScaleOnAxis();
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
  void onClose() {
    _animController.dispose();
    transformationController.removeListener(_scaleListener);
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    size = widgetRect.size;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String generateUniqueId() {
    return const Uuid().v1();
  }

  void addNode([NodeController? controller]) {
    controller ??= NodeController();
    controller.blueprint = this;

    var node = Node(generateUniqueId(), controller);
    _nodes.add(node);
  }

  void addNodes(List<NodeController> nodes) {
    for (var node in nodes) {
      addNode(node);
    }
  }

  void updateCanvasSize() {
    double w = 0;
    double h = 0;

    for (var node in _nodes) {
      var ctrl = Get.find<NodeController>(tag: node.id);

      // get top right edge position of this node
      Offset bottomRightEdge =
          ctrl.position + Offset(ctrl.size.width, ctrl.size.height);

      w = max(w, bottomRightEdge.dx);
      h = max(h, bottomRightEdge.dy);
    }

    w = max(w + widgetRect.width / 2, widgetRect.width);
    h = max(h + widgetRect.height / 2, widgetRect.height);

    size = Size(w, h);
  }

  void animateTo(NodeController node) {
    lastDraggedNode.value = node;
    // var offset = transformationController.toScene(position);
    Offset nodePos = node.position;
    Size nodeSize = node.size;

    Size widgetSize = Size(
      min(widgetRect.width, Get.width),
      min(widgetRect.height, Get.height),
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
    // ..setFromTranslationRotationScale(
    //   translation,
    //   Quaternion.identity(),
    //   _scale,
    // );

    _animController.reset();
    _anim = Matrix4Tween(
      begin: transformationController.value,
      end: scrollEnd,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _anim!.addListener(_onAnimateReset);
    _animController.forward();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onAnimateReset() {
    transformationController.value = _anim!.value;
    if (!_animController.isAnimating) {
      _anim!.removeListener(_onAnimateReset);
      _anim = null;
      _animController.reset();
    }
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _animController.stop();
    _anim?.removeListener(_onAnimateReset);
    _anim = null;
    _animController.reset();
  }

  void onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_animController.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }
}
