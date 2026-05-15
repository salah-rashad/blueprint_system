import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:blueprint_system/src/models/blueprint_theme.dart';
import 'package:blueprint_system/src/models/connection.dart';
import 'package:blueprint_system/src/models/node_events.dart';
import 'package:blueprint_system/src/models/port_data.dart';
import 'package:blueprint_system/src/utils/event.dart';
import 'package:blueprint_system/src/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;
import 'package:yaml/yaml.dart';
import 'package:xml/xml.dart';

import 'widgets/draggable_node/draggable_node.dart';
import 'widgets/fixed_node/fixed_node.dart';
import 'widgets/floating_node/floating_node.dart';
import 'widgets/floating_node/floating_node_controller.dart';
import 'widgets/node/node.dart';
import 'widgets/node/node_controller.dart';

class BlueprintController extends FullLifeCycleController
    with GetTickerProviderStateMixin {
  BlueprintController._(this.id);

  static BlueprintController get instance {
    var id = "/${const Uuid().v4()}";
    BlueprintController newInstance =
        Get.put(BlueprintController._(id), tag: id);
    return newInstance;
  }

  final String id;
  Size minSize = Size.zero;
  Size maxSize = Size.infinite;
  bool followNewAddedNodes = true;
  NodeEvents nodeGlobalEvents = NodeEvents();

  Event<ScaleStartDetails, void Function(ScaleStartDetails details)>
      onInteractionStart = Event();
  Event<ScaleEndDetails, void Function(ScaleEndDetails details)>
      onInteractionEnd = Event();
  Event<ScaleUpdateDetails, void Function(ScaleUpdateDetails details)>
      onInteractionUpdate = Event();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool snapToGrid = false;

  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey stackKey = GlobalKey();

  final Rxn<NodeController> _focusedNode = Rxn();
  NodeController? get focusedNode => _focusedNode.value;
  set focusedNode(NodeController? value) => _focusedNode.value = value;

  final Rx<List<Node>> _nodes = Rx(List.empty(growable: true));
  List<Node> get nodes => _nodes.value;

  //~~~~~~~~~~~~~~~~~~~~~~~~ CONNECTIONS ~~~~~~~~~~~~~~~~~~~~~~~~

  final RxList<Connection> _connections = RxList<Connection>([]);
  List<Connection> get connections => _connections;

  /// Add a connection between two nodes.
  void addConnection(Connection connection) {
    _connections.add(connection);
  }

  /// Remove a connection by id.
  void removeConnection(String id) {
    _connections.removeWhere((c) => c.id == id);
  }

  /// Remove all connections involving a specific node.
  void removeNodeConnections(String nodeId) {
    _connections.removeWhere(
        (c) => c.sourceNodeId == nodeId || c.targetNodeId == nodeId);
  }

  /// Clear all connections.
  void clearConnections() {
    _connections.clear();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~ SERIALIZATION ~~~~~~~~~~~~~~~~~~~~~~~~

  /// Export all nodes and connections to a JSON string.
  String exportToJson() {
    return const JsonEncoder.withIndent('  ').convert(_buildExportMap());
  }

  /// Export all nodes and connections to a YAML string.
  String exportToYaml() {
    return _toYamlString(_buildExportMap());
  }

  /// Convert a Dart value to a YAML string (simple encoder).
  String _toYamlString(dynamic data, [String indent = '']) {
    if (data == null) return 'null';
    if (data is String) {
      // Quote strings that need quoting
      if (data.contains(RegExp(r'[:\[\]#{}|>&*!%@`\n"]')) || data.isEmpty) {
        return "'${data.replaceAll("'", "''")}'";
      }
      return data;
    }
    if (data is num || data is bool) return data.toString();
    if (data is Map) {
      if (data.isEmpty) return '{}';
      final buffer = StringBuffer();
      for (final entry in data.entries) {
        final key = _toYamlString(entry.key);
        final value = entry.value;
        if (value is Map && value.isNotEmpty) {
          buffer.writeln('$indent$key:');
          buffer.write(_toYamlString(value, '$indent  '));
        } else if (value is List && value.isNotEmpty) {
          buffer.writeln('$indent$key:');
          buffer.write(_toYamlString(value, '$indent  '));
        } else {
          buffer.writeln('$indent$key: ${_toYamlString(value)}');
        }
      }
      return buffer.toString();
    }
    if (data is List) {
      if (data.isEmpty) return '[]';
      final buffer = StringBuffer();
      for (final item in data) {
        if (item is Map || item is List) {
          buffer.writeln('$indent-');
          final nested = _toYamlString(item, '$indent  ');
          buffer.write(nested);
          if (!nested.endsWith('\n')) buffer.writeln();
        } else {
          buffer.writeln('$indent- ${_toYamlString(item)}');
        }
      }
      return buffer.toString();
    }
    return data.toString();
  }

  /// Export all nodes and connections to an XML string.
  String exportToXml() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('blueprint', nest: () {
      builder.element('version', nest: '0.1.2');
      builder.element('nodes', nest: () {
        for (final node in nodes) {
          final nd = node.toJson();
          builder.element('node', nest: () {
            nd.forEach((key, value) {
              builder.element(key, nest: value?.toString() ?? '');
            });
          });
        }
      });
      builder.element('connections', nest: () {
        for (final conn in connections) {
          final cd = conn.toJson();
          builder.element('connection', nest: () {
            cd.forEach((key, value) {
              builder.element(key, nest: value?.toString() ?? '');
            });
          });
        }
      });
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Build the shared data map for all export formats.
  Map<String, dynamic> _buildExportMap() => {
        'version': '0.1.2',
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'connections': connections.map((c) => c.toJson()).toList(),
      };

  /// Import nodes and connections from a JSON string.
  void importFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      _importFromMap(data);
    } catch (e) {
      dev.log('Failed to import JSON: $e', name: 'BlueprintController');
    }
  }

  /// Import nodes and connections from a YAML string.
  void importFromYaml(String yamlString) {
    try {
      final data = _yamlToMap(loadYaml(yamlString));
      _importFromMap(data);
    } catch (e) {
      dev.log('Failed to import YAML: $e', name: 'BlueprintController');
    }
  }

  /// Import nodes and connections from an XML string.
  void importFromXml(String xmlString) {
    try {
      final data = _xmlToImportMap(xmlString);
      _importFromMap(data);
    } catch (e) {
      dev.log('Failed to import XML: $e', name: 'BlueprintController');
    }
  }

  /// Convert a YAML dynamic result into a proper Map<String, dynamic>.
  Map<String, dynamic> _yamlToMap(dynamic yaml) {
    return _deepCast(yaml) as Map<String, dynamic>;
  }

  /// Deep-cast a YAML/JSON dynamic tree to Map<String, dynamic>/List<dynamic>.
  dynamic _deepCast(dynamic value) {
    if (value is YamlMap) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map((e) => MapEntry(e.key.toString(), _deepCast(e.value))),
      );
    }
    if (value is YamlList) {
      return value.map(_deepCast).toList();
    }
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map((e) => MapEntry(e.key.toString(), _deepCast(e.value))),
      );
    }
    if (value is List) {
      return value.map(_deepCast).toList();
    }
    return value;
  }

  /// Parse an XML string into the import map format.
  Map<String, dynamic> _xmlToImportMap(String xmlString) {
    final doc = XmlDocument.parse(xmlString);
    final root = doc.rootElement;
    final nodesEl = root.findElements('nodes').firstOrNull;
    final connsEl = root.findElements('connections').firstOrNull;

    final nodesList = <dynamic>[];
    if (nodesEl != null) {
      for (final nodeEl in nodesEl.findElements('node')) {
        nodesList.add(_xmlElementToMap(nodeEl));
      }
    }

    final connsList = <dynamic>[];
    if (connsEl != null) {
      for (final connEl in connsEl.findElements('connection')) {
        connsList.add(_xmlElementToMap(connEl));
      }
    }

    return {
      'version': root.findElements('version').firstOrNull?.innerText ?? '0.1.2',
      'nodes': nodesList,
      'connections': connsList,
    };
  }

  Map<String, dynamic> _xmlElementToMap(XmlElement element) {
    final map = <String, dynamic>{};
    for (final child in element.childElements) {
      map[child.localName] = child.innerText;
    }
    return map;
  }

  /// Core import logic shared by JSON, YAML, and XML.
  void _importFromMap(Map<String, dynamic> data) {

    // Clear existing nodes safely
    for (var node in List<Node>.from(nodes)) {
      node.blueprint?.nodes.remove(node);
      node.dispose();
    }
    clearConnections();

    // Import nodes
    final nodesData = data['nodes'] as List<dynamic>;
    for (final nodeData in nodesData) {
      final nd = nodeData as Map<String, dynamic>;
      final type = nd['type'] as String;
      final childData = nd['child'] as Map<String, dynamic>?;

      Node? node;
      switch (type) {
        case 'FixedNode':
          node = FixedNode(
            id: nd['id'] as String?,
            initPosition: Offset(
              (nd['initPositionX'] as num).toDouble(),
              (nd['initPositionY'] as num).toDouble(),
            ),
            initSize: Size(
              (nd['initSizeWidth'] as num).toDouble(),
              (nd['initSizeHeight'] as num).toDouble(),
            ),
            priority: nd['priority'] as int? ?? 1,
            child: childData != null
                ? (_) => _buildChildFromData(childData)
                : null,
          );
          break;
        case 'DraggableNode':
          node = DraggableNode(
            id: nd['id'] as String?,
            initPosition: Offset(
              (nd['initPositionX'] as num).toDouble(),
              (nd['initPositionY'] as num).toDouble(),
            ),
            initSize: Size(
              (nd['initSizeWidth'] as num).toDouble(),
              (nd['initSizeHeight'] as num).toDouble(),
            ),
            priority: nd['priority'] as int? ?? 1,
            child: childData != null
                ? (_) => _buildChildFromData(childData)
                : null,
          );
          break;
        case 'FloatingNode':
          node = FloatingNode(
            id: nd['id'] as String?,
            initPosition: Offset(
              (nd['initPositionX'] as num).toDouble(),
              (nd['initPositionY'] as num).toDouble(),
            ),
            initSize: Size(
              (nd['initSizeWidth'] as num).toDouble(),
              (nd['initSizeHeight'] as num).toDouble(),
            ),
            priority: nd['priority'] as int? ?? 1,
            constraint: nd.containsKey('constraint')
                ? Constraint.values.firstWhere(
                    (c) => c.name == nd['constraint'],
                    orElse: () => Constraint.NONE,
                  )
                : Constraint.NONE,
            sizeFixed: nd['sizeFixed'] as bool? ?? true,
            responsiveToScreen:
                nd['responsiveToScreen'] as bool? ?? false,
          );
          break;
      }

      if (node != null) {
        addNode(node);

        // Restore ports if present in serialized data
        final portsData = nd['ports'] as List<dynamic>?;
        if (portsData != null) {
          node.controller.ports = portsData
              .map((p) => PortData.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
    }

    // Import connections
    final connectionsData = data['connections'] as List<dynamic>?;
    if (connectionsData != null) {
      for (final connData in connectionsData) {
        _connections.add(Connection.fromJson(connData as Map<String, dynamic>));
      }
    }
  }

  /// Helper to build a placeholder child widget from serialized data.
  Widget _buildChildFromData(Map<String, dynamic> data) {
    final colorValue = data['color'] as int? ?? 0xFF2196F3;
    return Container(
      color: Color(colorValue),
      alignment: Alignment.center,
      child: Text(
        data['label'] as String? ?? '',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Vector3 get _translation => transformationController.value.getTranslation();
  Rect? get getRect => stackKey.globalPaintBounds;

  Offset get cameraPosition =>
      Offset(_translation.x.abs(), _translation.y.abs());
  Size? get cameraSize => widgetKey.globalPaintBounds?.size;

  Size? get resolvedSize => (cameraSize! + cameraPosition) / scale;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final Rx<double> _scale = Rx(1);
  double get scale => _scale.value;

  final Rx<Size> _size = Rx<Size>(Size.zero);
  /// Exposed for internal reactive listeners (e.g. responsive FloatingNode).
  Rx<Size> get sizeRx => _size;
  Size get size => _size.value;
  set size(Size value) => _size.value = value;

  final Rx<bool> _showGrid = Rx(true);
  bool get showGrid => _showGrid.value;
  set showGrid(bool value) => _showGrid.value = value;

  final Rx<BlueprintTheme> _theme = Rx(BlueprintTheme.dark());
  BlueprintTheme get theme => _theme.value;
  set theme(BlueprintTheme value) => _theme.value = value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var transformationController = TransformationController();

  Animation<Matrix4>? _anim;
  late final AnimationController _animController;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _scaleListener() {
    _scale.value = transformationController.value.getMaxScaleOnAxis();
  }

  @override
  void onInit() {
    super.onInit();
    transformationController.addListener(_scaleListener);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void onReady() {
    super.onReady();
    size = cameraSize!;

    transformationController.addListener(onInteractionUpdate.invoke);
    WidgetsBinding.instance.addObserver(this);
    updateCanvasSize();
  }

  @override
  void onClose() {
    _animController.dispose();
    transformationController.removeListener(_scaleListener);
    WidgetsBinding.instance.removeObserver(this);

    super.onClose();
  }

  @override
  Future<void> dispose() async {
    Get.delete<BlueprintController>(tag: id);
    for (var node in nodes) {
      await node.dispose();
    }
    super.dispose();
  }

  @override
  Future<void> didChangeMetrics() async {
    // await for widget to initialize, then update size.
    await Future.delayed(const Duration(milliseconds: 100));
    updateCanvasSize();

    var focused = focusedNode;
    if (focused != null) {
      // checks if the focused node is visible on screen or not,
      // if true, animate to it.
      Offset bottomRightEdge =
          focused.position + Offset(focused.size.width, focused.size.height);

      if (bottomRightEdge > cameraPosition) {
        animateTo(focused);
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void> addNode(Node node, [bool? follow]) async {
    String id = " // ${const Uuid().v4()}";

    var newNode = node.copyWith(id: node.id ?? id, blueprint: this);
    Get.lazyPut(() async => newNode.init, tag: node.id ?? id);
    nodes.add(newNode);

    await 0.1.delay();
    updateCanvasSize();
    if (follow ?? followNewAddedNodes && node is! FloatingNode) {
      animateTo(newNode.controller);
    }
  }

  void addNodes(Iterable<Node>? newNodes) {
    if (newNodes != null) {
      for (var node in newNodes) {
        addNode(node);
      }
    }
  }

  void updateCanvasSize() {
    // final width
    double w = 0;
    // final height
    double h = 0;

    // update size depending on every node's position and size
    for (var node in nodes) {
      var nodeCtrl = node.controller;

      if (nodeCtrl is FloatingNodeController) continue;

      // get bottom right edge position of this node
      Offset bottomRightEdge =
          nodeCtrl.position + Offset(nodeCtrl.size.width, nodeCtrl.size.height);

      w = max(w, bottomRightEdge.dx);
      h = max(h, bottomRightEdge.dy);
    }

    w = max(
      w + cameraSize!.width / 2,
      resolvedSize!.width + cameraSize!.width / scale,
    );
    h = max(
      h + cameraSize!.height / 2,
      resolvedSize!.height + cameraSize!.height / scale,
    );

    // apply minSize & maxSize
    w = max(minSize.width, min(w, maxSize.width));
    h = max(minSize.height, min(h, maxSize.height));

    size = Size(w, h);
  }

  void animateToLast() {
    if (nodes.isNotEmpty) {
      animateTo(nodes.last.controller);
    }
  }

  void animateTo(NodeController node) {
    try {
      var screenSize = MediaQuery.of(widgetKey.currentContext!).size;
      _focusedNode.value = node;

      Offset nodePos = node.position;
      Size nodeSize = node.size;

      Size widgetSize = Size(
        min(cameraSize!.width, screenSize.width),
        min(cameraSize!.height, screenSize.height),
      );

      Matrix4 scrollEnd = Matrix4.identity();

      var x = (widgetSize.width / 2) - (nodeSize.width / 2) - nodePos.dx;
      var y = (widgetSize.height / 2) - (nodeSize.height / 2) - nodePos.dy;

      Vector3 translation = Vector3(
        min(0, max(x, widgetSize.width - size.width)),
        min(0, max(y, widgetSize.height - size.height)),
        0,
      );

      scrollEnd.setTranslation(translation);

      _stopAnim();
      _anim = Matrix4Tween(
        begin: transformationController.value,
        end: scrollEnd,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _anim!.addListener(_onAnimate);
      _animController.forward();
    } catch (error, stacktrace) {
      dev.log(
        "An error occured while animating to ${node.runtimeType} [${node.id}]",
        name: "ERROR",
        error: error,
        stackTrace: stacktrace,
      );
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onAnimate() {
    transformationController.value = _anim!.value;
    if (!_animController.isAnimating) {
      _anim!.removeListener(_onAnimate);
      _anim = null;
      _animController.reset();
    }
  }

// Stop a running reset to home transform animation.
  void _stopAnim() {
    _animController.stop();
    _anim?.removeListener(_onAnimate);
    _anim = null;
    _animController.reset();
  }

  void onInteractionStart_(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_animController.status == AnimationStatus.forward) {
      _stopAnim();
    }
  }

  void onInteractionUpdate_(ScaleUpdateDetails details) {
    double trigger = 200 / scale;
    if (resolvedSize != null) {
      if (resolvedSize!.width + trigger >= size.width ||
          resolvedSize!.height + trigger >= size.height ||
          size.width - resolvedSize!.width > cameraSize!.width / scale ||
          size.height - resolvedSize!.height > cameraSize!.width / scale) {
        updateCanvasSize();
      }
    }
  }
}
