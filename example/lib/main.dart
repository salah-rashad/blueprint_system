import 'package:blueprint_system/blueprint.dart';
import 'package:blueprint_system/blueprint_controller.dart';
import 'package:blueprint_system/node/node_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Blueprint Example',
      home: MyHomePage(title: 'Blueprint Example'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BlueprintController controller = BlueprintController();

  bool _snapToGrid = false;
  bool _showGrid = true;

  snapToGrid(bool value) => setState(() {
        _snapToGrid = value;
        controller.snapToGrid = value;
      });

  showGrid() => setState(() {
        _showGrid = !_showGrid;
        controller.showGrid = _showGrid;
      });

  @override
  void initState() {
    controller.addNodes([
      NodeController(),
      NodeController(
        initPosition: const Offset(500, 10),
        initSize: const Size(100, 100),
      ),
      NodeController(
        initPosition: const Offset(50, 300),
        initSize: const Size(100, 200),
      ),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Switch(
            value: _snapToGrid,
            onChanged: snapToGrid,
          ),
          IconButton(
            onPressed: showGrid,
            icon: Icon(
              _showGrid ? Icons.grid_off_outlined : Icons.grid_on_outlined,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // SizedBox(width: MediaQuery.of(context).size.width * 0.3),
          Blueprint(controller),
          // SizedBox(width: MediaQuery.of(context).size.width * 0.3),
        ],
      ),
    );
  }
}
