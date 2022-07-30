// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:blueprint_system/src/widgets/node/node_controller.dart';
import 'package:get/get.dart';

enum Constraint {
  NONE,
  X,
  Y,
  XY,
  XScreen,
  YScreen,
  XYScreen,
}

class FloatingNodeController extends NodeController {
  FloatingNodeController({
    super.id,
    required super.initPosition,
    required super.initSize,
    required super.blueprint,
    required super.priority,
    required this.initialConstraint,
    required this.sizeFixed,
  });

  final Constraint initialConstraint;
  final bool sizeFixed;

  final Rx<Constraint> _constraint = Rx(Constraint.NONE);
  Constraint get constraint => _constraint.value;
  set constraint(Constraint value) => _constraint.value = value;

  Offset _screenPosition = Offset.zero;

  @override
  void onInit() {
    super.onInit();
    constraint = initialConstraint;
  }

  @override
  void onReady() {
    super.onReady();
    updatePosition(initPosition - blueprint!.cameraPosition);

    blueprint!.onInteractionUpdate + _onInteract;
  }

  @override
  void onClose() {
    blueprint!.onInteractionUpdate - _onInteract;
    super.onClose();
  }

  void updatePosition(Offset v) {
    double x = max(0, min(v.dx, blueprint!.cameraSize!.width));
    double y = max(0, min(v.dy, blueprint!.cameraSize!.height));
    _screenPosition = Offset(x, y);
    _onInteract();
  }

  void _onInteract([_]) {
    var cameraPos = blueprint!.cameraPosition;
    double x = max(0, cameraPos.dx + _screenPosition.dx);
    double y = max(0, cameraPos.dy + _screenPosition.dy);
    _updatePositionWithConstraint(Offset(x, y) / blueprint!.scale);
  }

  void _updatePositionWithConstraint(Offset newPosition) {
    double x = position.dx;
    double y = position.dy;

    switch (constraint) {
      case Constraint.NONE:
        x = newPosition.dx;
        y = newPosition.dy;
        break;
      case Constraint.X:
        y = newPosition.dy;
        break;
      case Constraint.Y:
        x = newPosition.dx;
        break;
      case Constraint.XY:
        return;
      case Constraint.XScreen:
        x = newPosition.dx;
        y = _screenPosition.dy / blueprint!.scale;
        break;
      case Constraint.YScreen:
        x = _screenPosition.dx / blueprint!.scale;
        y = newPosition.dy;
        break;

      case Constraint.XYScreen:
        x = _screenPosition.dx / blueprint!.scale;
        y = _screenPosition.dy / blueprint!.scale;
        break;
    }

    position = Offset(x, y);
  }
}
