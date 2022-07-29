import 'package:blueprint_system/widgets/node/node_controller.dart';

class FixedNodeController extends NodeController {
  FixedNodeController({
    super.id,
    required super.initPosition,
    required super.initSize,
    required super.blueprint,
    required super.priority,
  });
}
