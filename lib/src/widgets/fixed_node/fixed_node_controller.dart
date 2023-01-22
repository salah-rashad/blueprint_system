import 'dart:ui';

import '../node/node_controller.dart';

class FixedNodeController extends NodeController {
  FixedNodeController({
    required super.id,
    required super.initPosition,
    required super.initSize,
    required super.blueprint,
    required super.priority,
    required super.minSize,
  });

  @override
  Offset get position {
    return initPosition;
  }

  @override
  set position(Offset value) {
    return;
  }
}
