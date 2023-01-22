import 'dart:ui';

import '../utils/event.dart';
import '../widgets/node/node_controller.dart';

class NodeEvents {
  NodeEvents();

  // Event<Offset, void Function(Offset pos)> onNodeDragStart = Event();
  // Event<Offset, void Function(Offset pos)> onNodeDragUpdate = Event();

  Event3<
      NodeController,
      Offset,
      Offset,
      void Function(
    NodeController node,
    Offset oldValue,
    Offset newValue,
  )> onMoved = Event3();

  Event<Size, void Function(Size size)> onNodeResizeStart = Event();
  Event2<Offset, Size, void Function(Offset pos, Size size)>
      onNodeResizeUpdate = Event2();
  Event5<
      NodeController,
      Offset,
      Offset,
      Size,
      Size,
      void Function(
    NodeController node,
    Offset posOldValue,
    Offset posNewValue,
    Size sizeOldValue,
    Size sizeNewValue,
  )> onResized = Event5();

  // Event2<NodeController, Offset> onPositionChanged = Event2();
  // Event2<NodeController, Size> onSizeChanged = Event2();
}
