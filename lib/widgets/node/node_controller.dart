import 'package:blueprint_system/blueprint_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class NodeController extends GetxController {
  NodeController(this.initPosition, this.initSize);

  final Offset initPosition;
  final Size initSize;

  late BlueprintController blueprint;

  final _position = Rx<Offset>(Offset.zero);
  Offset get position => _position.value;
  set position(Offset value) => _position.value = value;

  final _size = Rx<Size>(Size.zero);
  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  // Size get sizeScaled => _size.value * (blueprint.scale);

  @override
  void onReady() {
    position = initPosition;
    size = initSize;
  }
}
