import 'package:blueprint_system/blueprint_system.dart';
import 'package:example/utils/shortcut_actions.dart';
import 'package:example/widgets/node_container.dart';
import 'package:flutter/material.dart';
import 'package:undo/undo.dart';

import '../widgets/resizable_node.dart';

class DevPage extends StatefulWidget {
  const DevPage({Key? key}) : super(key: key);

  @override
  State<DevPage> createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  BlueprintController controller = BlueprintController.instance;
  ChangeStack changes = ChangeStack();
  FocusNode focusNode = FocusNode();

  Map<ShortcutActivator, VoidCallback> get _callbackBindings => {
        UndoAction(): () => setState(changes.undo),
        RedoAction(): () => setState(changes.redo),
      };

  bool _snapToGrid = false;
  bool _showGrid = true;

  void snapToGrid(bool value) => setState(() {
        _snapToGrid = value;
        controller.snapToGrid = value;
      });

  void showGrid() => setState(() {
        _showGrid = !_showGrid;
        controller.showGrid = _showGrid;
      });

  @override
  void initState() {
    super.initState();

    var node1 = ResizableNode(
      child: (c) => NodeContainer(
        controller: c,
        color: Colors.red,
        text: c.size.toString(),
      ),
    );

    var node2 = DraggableNode(
      initPosition: const Offset(800, 400),
      child: (c) => NodeContainer(
        controller: c,
        color: Colors.green,
        text: c.size.toString(),
      ),
    );

    controller.addNodes([node1, node2]);

    controller.nodeGlobalEvents.onMoved + _onNodeMoved;
    controller.nodeGlobalEvents.onResized + _onNodeResized;
  }

  void _onNodeMoved(
    NodeController node,
    Offset oldValue,
    Offset newValue,
  ) {
    changes.add<Offset>(
      Change(
        oldValue,
        () => node.position = newValue,
        (oldValue) => node.position = oldValue,
      ),
    );
    setState(() {});
  }

  void _onNodeResized(
    NodeController node,
    Offset posOldValue,
    Offset posNewValue,
    Size sizeOldValue,
    Size sizeNewValue,
  ) {
    changes.addGroup([
      Change<Offset>(
        posOldValue,
        () => node.position = posNewValue,
        (oldValue) => node.position = oldValue,
      ),
      Change<Size>(
        sizeOldValue,
        () => node.size = sizeNewValue,
        (oldValue) => node.size = oldValue,
      ),
    ]);
    setState(() {});
  }

  @override
  void dispose() {
    controller.nodeGlobalEvents.onMoved - _onNodeMoved;
    controller.nodeGlobalEvents.onResized - _onNodeResized;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Development Page"),
        actions: [
          IconButton(
            onPressed: !changes.canUndo ? null : () => setState(changes.undo),
            tooltip: "Undo",
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            onPressed: !changes.canRedo ? null : () => setState(changes.redo),
            tooltip: "Redo",
            icon: const Icon(Icons.redo_rounded),
          ),
          const SizedBox(
            width: 32.0,
          ),
          Tooltip(
            message: "Snap to grid",
            child: Switch(
              value: _snapToGrid,
              onChanged: snapToGrid,
              activeTrackColor: Colors.blueAccent,
              activeColor: Colors.blueAccent,
            ),
          ),
          IconButton(
            onPressed: showGrid,
            tooltip: _showGrid ? "Hide Grid" : "Show Grid",
            icon: Icon(
              _showGrid ? Icons.grid_off_outlined : Icons.grid_on_outlined,
            ),
          ),
        ],
      ),
      body: CallbackShortcuts(
        bindings: _callbackBindings,
        child: Focus(
          focusNode: focusNode,
          autofocus: true,
          onFocusChange: (value) {
            if (!value) {
              focusNode.requestFocus();
            }
          },
          child: Blueprint(
            controller: controller,
            children: [
              FloatingNode(
                initSize: const Size(300, 500),
                initPosition: Offset(size.width - 332, 64),
                child: infoPanel,
                focusEnabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoPanel(FloatingNodeController c) {
    NodeController? focused = controller.focusedNode;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white38,
      child: Column(
        children: <String, dynamic>{
          "Blueprint Size:": "${controller.size}",
          "-----------": "-----------",
          if (focused != null) ...{
            "Type:": focused.runtimeType,
            "Position:": focused.position,
            "Size:": focused.size,
            "Resizable:": resizeCheckbox(focused),
          }
        }
            .entries
            .map<Widget>(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(e.key)),
                    Expanded(
                      child: e.value is Widget
                          ? e.value
                          : Text(e.value.toString()),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget resizeCheckbox(NodeController c) {
    return CheckboxListTile(
      value: c.resizable,
      // title: const Text("Resizable"),
      onChanged: (v) => c.resizable = v!,
      dense: true,
    );
  }
}
