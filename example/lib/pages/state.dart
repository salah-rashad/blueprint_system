import 'package:blueprint_system/blueprint_system.dart';
import 'package:flutter/material.dart';

abstract class StateClass<T extends StatefulWidget> extends State<T> {
  StateClass(this.title);
  final String title;

  BlueprintController controller = BlueprintController.instance;

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

  Widget child(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
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
      body: child(context),
    );
  }
}
