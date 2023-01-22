import 'package:blueprint_system/blueprint_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SizeHandleController extends GetxController {
  final NodeController nodeController;
  final Alignment alignment;
  SizeHandleController(this.nodeController, this.alignment);

  final _hover = RxBool(false);
  final _show = RxBool(false);

  bool get hover => _hover.value;
  set hover(bool v) => _hover.value = v;

  bool get show => _show.value;
  set show(bool v) => _show.value = v;

  double get _x => nodeController.position.dx;
  double get _y => nodeController.position.dy;
  double get _width => nodeController.size.width;
  double get _height => nodeController.size.height;

  BlueprintController? get blueprint => nodeController.blueprint;

  double get blueprintScale => blueprint?.scale ?? 1.0;

  final _center = Rx<Offset>(Offset.zero);
  final _size = Rx<Size>(Size.zero);
  final _cursor = Rx<MouseCursor>(MouseCursor.defer);
  final _dragAnchor = Rx<Offset>(Offset.zero);

  Offset get center => _center.value;
  set center(value) => _center.value = value;

  Size get size {
    Axis? axis = getAxis();
    switch (axis) {
      case Axis.horizontal:
        return Size(_size.value.width / blueprintScale, _size.value.height);
      case Axis.vertical:
        return Size(_size.value.width, _size.value.height / blueprintScale);

      default:
        return _size.value;
    }
  }

  set size(Size value) => _size.value = value;

  MouseCursor get cursor => _cursor.value;
  set cursor(MouseCursor value) => _cursor.value = value;

  Offset get dragAnchor => _dragAnchor.value;
  set dragAnchor(Offset value) => _dragAnchor.value = value;

  Offset dragAnchorStrategy(
          Draggable<Object> draggable, BuildContext context, Offset position) =>
      dragAnchor * blueprintScale;

  Offset _dragStartPos = const Offset(1, 1);
  Size _dragStartSize = const Size(1, 1);

  @override
  void onReady() {
    updateValues();
    nodeController.onPositionChanged + (oldValue, newValue) => updateValues();
    nodeController.onSizeChanged + (oldValue, newValue) => updateValues();
    super.onReady();
  }

  @override
  void onClose() {
    nodeController.onPositionChanged - (oldValue, newValue) => updateValues();
    nodeController.onSizeChanged - (oldValue, newValue) => updateValues();
    super.onClose();
  }

  void updateValues({
    double weight = 12,
    double padding = 0,
  }) {
    double scale = 1.0;
    var w = _width - (weight * 2);
    var h = _height - (weight * 2);
    // directional

    // left
    if (alignment == Alignment.centerLeft) {
      center = Offset(_x - padding, _y + _height / 2).translate(-weight / 2, 0);
      size = Size(weight, h * scale);
      cursor = SystemMouseCursors.resizeLeftRight;
    }
    //right
    else if (alignment == Alignment.centerRight) {
      center = Offset(_x + _width + padding, _y + _height / 2)
          .translate(weight / 2, 0);
      size = Size(weight, h * scale);
      cursor = SystemMouseCursors.resizeLeftRight;
    }
    // top
    else if (alignment == Alignment.topCenter) {
      center = Offset(_x + _width / 2, _y - padding).translate(0, -weight / 2);
      size = Size(w * scale, weight);
      cursor = SystemMouseCursors.resizeUpDown;
    }
    // bottom
    else if (alignment == Alignment.bottomCenter) {
      center = Offset(_x + _width / 2, _y + _height + padding)
          .translate(0, weight / 2);
      size = Size(w * scale, weight);
      cursor = SystemMouseCursors.resizeUpDown;
    }

    // diagonal

    // top left
    else if (alignment == Alignment.topLeft) {
      center = Offset(_x - padding, _y - padding).translate(0, 0);
      size = Size(weight, weight) * 2;
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
    }
    // top right
    else if (alignment == Alignment.topRight) {
      center = Offset(_x + _width + padding, _y - padding).translate(0, 0);
      size = Size(weight, weight) * 2;
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
    }
    // bottom left
    else if (alignment == Alignment.bottomLeft) {
      center = Offset(_x - padding, _y + _height + padding).translate(0, 0);
      size = Size(weight, weight) * 2;
      cursor = SystemMouseCursors.resizeUpRightDownLeft;
    }
    // bottom right
    else if (alignment == Alignment.bottomRight) {
      center =
          Offset(_x + _width + padding, _y + _height + padding).translate(0, 0);
      size = Size(weight, weight) * 2;
      cursor = SystemMouseCursors.resizeUpLeftDownRight;
    } else {
      center = Offset.zero;
      size = Size(weight, weight);
      cursor = MouseCursor.defer;
    }
  }

  void onDragStarted() {
    _dragStartPos = nodeController.position;
    _dragStartSize = nodeController.size;

    // blueprint?.nodeGlobalCallbacks.onNodeResizeStart
    //     .invoke(nodeController.size);
  }

  void onDragUpdate(DragUpdateDetails details) {
    var node = nodeController;
    Offset pointerOffset =
        details.localPosition - (node.position * node.blueprint!.scale);
    // Offset pos2 =
    //     details.localPosition - (_dragStartPos * node.blueprint!.scale);
    var position = NodeController.calculateOffset(
        details.localPosition, node.size, node.blueprint!)!;

    var sizeOffset = NodeController.calculateOffset(
        pointerOffset, node.size, node.blueprint!)!;

    // ⟶
    if (alignment == Alignment.centerRight) {
      node.size = Size(sizeOffset.dx, node.height);
    }
    // ↓
    else if (alignment == Alignment.bottomCenter) {
      node.size = Size(node.width, sizeOffset.dy);
    }
    // ⟵
    else if (alignment == Alignment.centerLeft) {
      node.size = Size(
        _dragStartSize.width + _dragStartPos.dx - position.dx,
        node.height,
      );
      if (node.size.width == node.minSize.width) {
        node.position = Offset(
          _dragStartPos.dx + (_dragStartSize.width - node.minSize.width),
          node.y,
        );
        return;
      }

      node.position = Offset(position.dx, node.y);
    }
    // ↑
    else if (alignment == Alignment.topCenter) {
      node.size = Size(
        node.width,
        _dragStartSize.height + _dragStartPos.dy - position.dy,
      );
      if (node.size.height == node.minSize.height) {
        node.position = Offset(
          node.x,
          _dragStartPos.dy + (_dragStartSize.height - node.minSize.height),
        );
        return;
      }

      node.position = Offset(node.x, position.dy);
    }
    // ↗
    else if (alignment == Alignment.topRight) {
      node.size = Size(
        sizeOffset.dx,
        _dragStartSize.height + _dragStartPos.dy - position.dy,
      );

      double x = node.x;
      double y = position.dy;

      if (node.size.height == node.minSize.height) {
        y = _dragStartPos.dy + (_dragStartSize.height - node.minSize.height);
      }

      node.position = Offset(x, y);
    }
    // ↖
    else if (alignment == Alignment.topLeft) {
      node.size = Size(
        _dragStartSize.width + _dragStartPos.dx - position.dx,
        _dragStartSize.height + _dragStartPos.dy - position.dy,
      );

      double? x;
      double? y;

      if (node.size.width == node.minSize.width) {
        x = _dragStartPos.dx + (_dragStartSize.width - node.minSize.width);
      }
      if (node.size.height == node.minSize.height) {
        y = _dragStartPos.dy + (_dragStartSize.height - node.minSize.height);
      }

      node.position = Offset(x ?? position.dx, y ?? position.dy);
    }
    // ↘
    else if (alignment == Alignment.bottomRight) {
      node.size = Size(sizeOffset.dx, sizeOffset.dy);
    }
    // ↙
    else if (alignment == Alignment.bottomLeft) {
      node.size = Size(
        _dragStartSize.width + _dragStartPos.dx - position.dx,
        sizeOffset.dy,
      );

      double x = position.dx;
      double y = node.y;

      if (node.size.width == node.minSize.width) {
        x = _dragStartPos.dx + (_dragStartSize.width - node.minSize.width);
      }

      node.position = Offset(x, y);
    }

    // blueprint?.nodeGlobalCallbacks.onNodeResizeUpdate
    //     .invoke(details, node.position, node.size);
  }

  Future<void> onDragEnd(DraggableDetails details) async {
    // nodeController.savePosition(nodeController.position, _dragStartPos);
    // nodeController.saveSize(nodeController.size, _dragStartSize);

    blueprint?.nodeGlobalEvents.onResized.invoke(
      nodeController,
      _dragStartPos,
      nodeController.position,
      _dragStartSize,
      nodeController.size,
    );
  }

  Axis? getAxis() {
    if (alignment == Alignment.centerRight ||
        alignment == Alignment.centerLeft) {
      return Axis.horizontal;
    } else if (alignment == Alignment.topCenter ||
        alignment == Alignment.bottomCenter) {
      return Axis.vertical;
    } else {
      return null;
    }
  }
}
