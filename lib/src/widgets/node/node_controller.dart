import 'dart:math';

import 'package:blueprint_system/src/utils/extensions.dart';
import 'package:blueprint_system/src/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/event.dart';

abstract class NodeController extends GetxController {
  NodeController({
    required this.id,
    required this.initPosition,
    required this.initSize,
    required this.blueprint,
    required this.priority,
    required this.minSize,
  });

  final String? id;
  final Offset initPosition;
  final Size initSize;
  final int priority;
  final Size minSize;

  BlueprintController? blueprint;

  final _position = Rx(Offset.zero);
  Offset get position => _position.value;
  set position(Offset value) {
    Offset oldValue = _position.value;

    _position.value = value;
    onPositionChanged.invoke(oldValue, value);
  }

  final _size = Rx<Size>(Size.zero);
  Size get size => _size.value;
  set size(Size value) {
    Size oldValue = _size.value;

    Size finalValue = value;

    if (value >= minSize) {
      finalValue = value;
    } else if (value < minSize) {
      finalValue = minSize;
    } else if (value.width < minSize.width) {
      finalValue = Size(minSize.width, value.height);
    } else if (value.height < minSize.height) {
      finalValue = Size(value.width, minSize.height);
    }
    _size.value = finalValue;
    onSizeChanged.invoke(oldValue, value);
    blueprint?.updateCanvasSize();
  }

  final _resizable = Rx(false);
  bool get resizable => _resizable.value;
  set resizable(bool value) => _resizable.value = value;

  Event2<Offset, Offset, void Function(Offset oldValue, Offset newValue)>
      onPositionChanged = Event2();
  Event2<Size, Size, void Function(Size oldValue, Size newValue)>
      onSizeChanged = Event2();

  double get x => position.dx;
  double get y => position.dy;
  double get width => size.width;
  double get height => size.height;
  Size get sizeScaled => _size.value * (blueprint?.scale ?? 1.0);

  @override
  void onReady() {
    position = initPosition;
    size = initSize;
  }

  static Offset? calculateOffset(
      Offset offset, Size size, BlueprintController blueprint) {
    var rect = blueprint.getRect;
    if (rect == null) return null;

    double x = (offset.dx - rect.left) / blueprint.scale;
    double y = (offset.dy - rect.top) / blueprint.scale;

    x = max(0, min(x, blueprint.maxSize.width - size.width));
    y = max(0, min(y, blueprint.maxSize.height - size.height));

    if (blueprint.snapToGrid) {
      x = x.roundBy(10).toDouble();
      y = y.roundBy(10).toDouble();
    }

    return Offset(x, y);
  }

  void remove() {
    blueprint?.nodes.removeWhere((element) => element.id == id);
    blueprint?.updateCanvasSize();
    if (blueprint?.nodes.isNotEmpty == true) {
      blueprint?.animateToLast();
    }
  }
}
