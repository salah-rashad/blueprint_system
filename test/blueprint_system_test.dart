import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blueprint_system/blueprint_system.dart';
import 'package:get/get.dart';

void main() {
  group('PortData', () {
    test('creates with default values', () {
      const port = PortData(
        id: 'port1',
        relativePosition: Offset(50, 100),
      );

      expect(port.id, 'port1');
      expect(port.relativePosition, const Offset(50, 100));
      expect(port.type, PortType.input);
      expect(port.label, '');
    });

    test('creates an output port', () {
      const port = PortData(
        id: 'out1',
        relativePosition: Offset(100, 0),
        type: PortType.output,
        label: 'Output',
      );

      expect(port.id, 'out1');
      expect(port.type, PortType.output);
      expect(port.label, 'Output');
    });

    test('copyWith creates modified copy', () {
      const port = PortData(
        id: 'port1',
        relativePosition: Offset(50, 100),
      );

      final modified = port.copyWith(
        label: 'New Label',
        type: PortType.output,
      );

      expect(modified.id, 'port1');
      expect(modified.label, 'New Label');
      expect(modified.type, PortType.output);
      expect(modified.relativePosition, const Offset(50, 100));
    });

    test('round-trip JSON serialization', () {
      const port = PortData(
        id: 'port1',
        label: 'Test Port',
        relativePosition: Offset(75, 150),
        type: PortType.output,
      );

      final json = port.toJson();
      final restored = PortData.fromJson(json);

      expect(restored.id, port.id);
      expect(restored.label, port.label);
      expect(restored.relativePosition, port.relativePosition);
      expect(restored.type, port.type);
    });

    test('fromJson defaults to PortType.input for unknown type string', () {
      final json = {
        'id': 'p1',
        'label': 'test',
        'relativePositionX': 0.0,
        'relativePositionY': 0.0,
        'type': 'unknown_type',
      };
      final port = PortData.fromJson(json);
      expect(port.type, PortType.input);
    });

    test('fromJson defaults label to empty string when absent', () {
      final json = {
        'id': 'p1',
        'relativePositionX': 10.0,
        'relativePositionY': 20.0,
        'type': 'output',
      };
      final port = PortData.fromJson(json);
      expect(port.label, '');
    });

    test('copyWith can update relativePosition only', () {
      const original = PortData(
        id: 'p1',
        relativePosition: Offset(0, 0),
        type: PortType.output,
        label: 'Out',
      );
      final moved = original.copyWith(relativePosition: const Offset(99, 42));
      expect(moved.relativePosition, const Offset(99, 42));
      expect(moved.id, original.id);
      expect(moved.type, original.type);
      expect(moved.label, original.label);
    });

    test('toJson stores type as its name string', () {
      const port = PortData(
        id: 'p1',
        relativePosition: Offset.zero,
        type: PortType.output,
      );
      expect(port.toJson()['type'], 'output');
    });

    test('fromJson restores output type correctly', () {
      const port = PortData(
        id: 'p1',
        relativePosition: Offset(5, 5),
        type: PortType.output,
      );
      final restored = PortData.fromJson(port.toJson());
      expect(restored.type, PortType.output);
    });
  });

  group('Connection', () {
    test('creates a connection between two ports', () {
      const conn = Connection(
        id: 'conn1',
        sourceNodeId: 'node1',
        sourcePortId: 'out1',
        targetNodeId: 'node2',
        targetPortId: 'in1',
      );

      expect(conn.id, 'conn1');
      expect(conn.sourceNodeId, 'node1');
      expect(conn.sourcePortId, 'out1');
      expect(conn.targetNodeId, 'node2');
      expect(conn.targetPortId, 'in1');
      expect(conn.color, Colors.white);
      expect(conn.strokeWidth, 2.0);
    });

    test('round-trip JSON serialization', () {
      const conn = Connection(
        id: 'conn1',
        sourceNodeId: 'node_a',
        sourcePortId: 'port_out_1',
        targetNodeId: 'node_b',
        targetPortId: 'port_in_2',
        color: Colors.green,
        strokeWidth: 3.0,
      );

      final json = conn.toJson();
      final restored = Connection.fromJson(json);

      expect(restored.id, conn.id);
      expect(restored.sourceNodeId, conn.sourceNodeId);
      expect(restored.sourcePortId, conn.sourcePortId);
      expect(restored.targetNodeId, conn.targetNodeId);
      expect(restored.targetPortId, conn.targetPortId);
      expect(restored.color.toARGB32(), conn.color.toARGB32());
      expect(restored.strokeWidth, conn.strokeWidth);
    });

    test('copyWith creates modified copy', () {
      const conn = Connection(
        id: 'conn1',
        sourceNodeId: 'node1',
        sourcePortId: 'out1',
        targetNodeId: 'node2',
        targetPortId: 'in1',
      );

      final modified = conn.copyWith(color: const Color(0xFF0000FF), strokeWidth: 5.0);
      expect(modified.id, 'conn1');
      expect(modified.color, const Color(0xFF0000FF));
      expect(modified.strokeWidth, 5.0);
    });

    test('fromJson uses default strokeWidth when missing', () {
      final json = {
        'id': 'c1',
        'sourceNodeId': 'n1',
        'sourcePortId': 'p1',
        'targetNodeId': 'n2',
        'targetPortId': 'p2',
        'color': Colors.white.toARGB32(),
        // 'strokeWidth' intentionally absent
      };
      final conn = Connection.fromJson(json);
      expect(conn.strokeWidth, 2.0);
    });

    test('copyWith preserves unchanged fields', () {
      const original = Connection(
        id: 'c1',
        sourceNodeId: 'src',
        sourcePortId: 'sp',
        targetNodeId: 'tgt',
        targetPortId: 'tp',
        color: Colors.blue,
        strokeWidth: 3.0,
      );

      final copy = original.copyWith(id: 'c2');
      expect(copy.id, 'c2');
      expect(copy.sourceNodeId, original.sourceNodeId);
      expect(copy.sourcePortId, original.sourcePortId);
      expect(copy.targetNodeId, original.targetNodeId);
      expect(copy.targetPortId, original.targetPortId);
      expect(copy.color.toARGB32(), original.color.toARGB32());
      expect(copy.strokeWidth, original.strokeWidth);
    });

    test('toJson produces correct key set', () {
      const conn = Connection(
        id: 'c1',
        sourceNodeId: 'n1',
        sourcePortId: 'p1',
        targetNodeId: 'n2',
        targetPortId: 'p2',
      );
      final json = conn.toJson();
      expect(json, containsKey('id'));
      expect(json, containsKey('sourceNodeId'));
      expect(json, containsKey('sourcePortId'));
      expect(json, containsKey('targetNodeId'));
      expect(json, containsKey('targetPortId'));
      expect(json, containsKey('color'));
      expect(json, containsKey('strokeWidth'));
    });

    test('default color is white serialized/restored correctly', () {
      const conn = Connection(
        id: 'c1',
        sourceNodeId: 'n1',
        sourcePortId: 'p1',
        targetNodeId: 'n2',
        targetPortId: 'p2',
      );
      final restored = Connection.fromJson(conn.toJson());
      expect(restored.color.toARGB32(), Colors.white.toARGB32());
    });
  });

  group('NodeEvents', () {
    test('onMoved event fires and can be unsubscribed', () {
      final events = NodeEvents();
      int callCount = 0;

      void handler(NodeController? node, Offset old, Offset newVal) {
        callCount++;
      }

      events.onMoved + handler;
      events.onMoved.invoke(null, const Offset(0, 0), const Offset(10, 10));
      expect(callCount, 1);

      events.onMoved - handler;
      events.onMoved.invoke(null, const Offset(0, 0), const Offset(20, 20));
      expect(callCount, 1);
    });

    test('onResized event fires correctly', () {
      final events = NodeEvents();
      int callCount = 0;

      void handler(NodeController? node, Offset posOld, Offset posNew,
          Size sizeOld, Size sizeNew) {
        callCount++;
        expect(posOld, const Offset(0, 0));
        expect(posNew, const Offset(10, 10));
        expect(sizeOld, const Size(100, 100));
        expect(sizeNew, const Size(200, 200));
      }

      events.onResized + handler;
      events.onResized.invoke(
        null,
        const Offset(0, 0),
        const Offset(10, 10),
        const Size(100, 100),
        const Size(200, 200),
      );
      expect(callCount, 1);
    });
  });

  group('RulerOptions', () {
    test('creates with default values', () {
      const options = RulerOptions();
      expect(options.interval, 100.0);
      expect(options.divisions, 1);
      expect(options.hideZero, true);
      expect(options.textColor, isNull);
    });

    test('asserts divisions > 0', () {
      expect(
        () => RulerOptions(divisions: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toJson round-trip with explicit textColor', () {
      const options = RulerOptions(
        textColor: Color(0xFFFF0000),
        interval: 50.0,
        divisions: 2,
        hideZero: false,
      );

      final json = options.toJson();
      final restored = RulerOptions.fromJson(json);

      expect(restored.textColor?.toARGB32(), options.textColor?.toARGB32());
      expect(restored.interval, options.interval);
      expect(restored.divisions, options.divisions);
      expect(restored.hideZero, options.hideZero);
    });

    test('toJson with null textColor serializes as null', () {
      const options = RulerOptions();
      final json = options.toJson();
      expect(json['textColor'], isNull);
    });

    test('fromJson restores null textColor correctly', () {
      const options = RulerOptions();
      final json = options.toJson();
      final restored = RulerOptions.fromJson(json);
      expect(restored.textColor, isNull);
    });

    test('fromJson uses default values when fields are absent', () {
      final restored = RulerOptions.fromJson({});
      expect(restored.textColor, isNull);
      expect(restored.interval, 100.0);
      expect(restored.divisions, 1);
      expect(restored.hideZero, true);
    });

    test('toJson contains all expected keys', () {
      const options = RulerOptions();
      final json = options.toJson();
      expect(json, containsKey('textColor'));
      expect(json, containsKey('interval'));
      expect(json, containsKey('divisions'));
      expect(json, containsKey('hideZero'));
    });

    test('fromJson round-trip with custom interval and divisions', () {
      const options = RulerOptions(interval: 200.0, divisions: 4, hideZero: false);
      final restored = RulerOptions.fromJson(options.toJson());
      expect(restored.interval, 200.0);
      expect(restored.divisions, 4);
      expect(restored.hideZero, false);
    });
  });

  group('NodeOptions', () {
    test('creates with default values', () {
      const options = NodeOptions();
      expect(options.initPosition, const Offset(100, 100));
      expect(options.initSize, const Size(200, 200));
      expect(options.priority, 1);
      expect(options.focusEnabled, true);
    });

    test('copyWith overrides specific values', () {
      const options = NodeOptions();
      final modified = options.copyWith(priority: 5, focusEnabled: false);
      expect(modified.priority, 5);
      expect(modified.focusEnabled, false);
      expect(modified.initPosition, options.initPosition);
    });
  });

  group('Extensions', () {
    test('roundBy rounds correctly', () {
      expect(43.roundBy(10), 40);
      expect(16.roundBy(10), 20);
      expect(68.roundBy(15), 75);
      expect(50.roundBy(100), 100);
      expect(0.roundBy(100), 0);
      expect(49.roundBy(100), 0);
    });

    test('isInteger check works', () {
      expect(5.isInteger, true);
      expect(5.0.isInteger, true);
      expect(5.5.isInteger, false);
    });
  });

  group('ActionsSaver', () {
    test('undo and redo work correctly', () {
      final rx = Rx<int>(0);
      final saver = _TestSaver();

      // Record change from 0→1, then manually apply it.
      saver.saveAction(rx, 1);
      rx.value = 1;
      expect(rx.value, 1);

      // Record change from 1→2, then manually apply it.
      saver.saveAction(rx, 2);
      rx.value = 2;
      expect(rx.value, 2);

      saver.undo();
      expect(rx.value, 1);

      saver.undo();
      expect(rx.value, 0);

      saver.redo();
      expect(rx.value, 1);

      saver.redo();
      expect(rx.value, 2);
    });

    test('clearHistory clears stacks', () {
      final rx = Rx<String>('a');
      final saver = _TestSaver();

      saver.saveAction(rx, 'b');
      saver.saveAction(rx, 'c');
      expect(saver.hasUndo, true);

      saver.clearHistory();
      expect(saver.hasUndo, false);
      expect(saver.hasRedo, false);
    });

    test('canUndo and canRedo track stack lengths', () {
      final rx = Rx<int>(0);
      final saver = _TestSaver();

      expect(saver.canUndo, 0);
      expect(saver.canRedo, 0);

      saver.saveAction(rx, 1);
      expect(saver.canUndo, 1);
      expect(saver.canRedo, 0);

      saver.saveAction(rx, 2);
      expect(saver.canUndo, 2);

      rx.value = 2;
      saver.undo();
      expect(saver.canUndo, 1);
      expect(saver.canRedo, 1);

      saver.undo();
      expect(saver.canUndo, 0);
      expect(saver.canRedo, 2);
    });

    test('undo on empty stack is a no-op', () {
      final rx = Rx<String>('original');
      final saver = _TestSaver();

      saver.undo(); // should not throw
      expect(rx.value, 'original');
    });

    test('redo on empty stack is a no-op', () {
      final rx = Rx<String>('original');
      final saver = _TestSaver();

      saver.redo(); // should not throw
      expect(rx.value, 'original');
    });

    test('new saveAction clears redo stack', () {
      final rx = Rx<int>(0);
      final saver = _TestSaver();

      saver.saveAction(rx, 1);
      rx.value = 1;
      saver.undo();
      expect(saver.hasRedo, true);

      // Saving a new action should clear the redo stack.
      saver.saveAction(rx, 2);
      expect(saver.hasRedo, false);
    });

    test('saveAction with explicit oldValue uses provided old, not current', () {
      final rx = Rx<int>(99);
      final saver = _TestSaver();

      // Pass explicit oldValue of 0, even though rx.value is 99.
      saver.saveAction(rx, 10, 0);
      saver.undo();

      // Undo should restore to 0 (the explicit old), not 99.
      expect(rx.value, 0);
    });

    test('saveActionGroup adds all actions to undo stack', () {
      final rx = Rx<int>(0);
      final saver = _TestSaver();

      final actions = [
        Action(redo: () => rx.value = 1, undo: () => rx.value = 0),
        Action(redo: () => rx.value = 2, undo: () => rx.value = 1),
      ];

      saver.saveActionGroup(actions);
      expect(saver.canUndo, 2);
      expect(saver.canRedo, 0);
    });

    test('saveActionGroup with empty list does nothing', () {
      final saver = _TestSaver();
      saver.saveActionGroup([]);
      expect(saver.canUndo, 0);
    });

    test('saveActionGroup clears redo stack', () {
      final rx = Rx<int>(0);
      final saver = _TestSaver();

      saver.saveAction(rx, 1);
      rx.value = 1;
      saver.undo();
      expect(saver.hasRedo, true);

      saver.saveActionGroup([
        Action(redo: () => rx.value = 5, undo: () => rx.value = 0),
      ]);
      expect(saver.hasRedo, false);
    });

    test('hasUndo and hasRedo report correctly after operations', () {
      final rx = Rx<bool>(false);
      final saver = _TestSaver();

      expect(saver.hasUndo, false);
      expect(saver.hasRedo, false);

      saver.saveAction(rx, true);
      expect(saver.hasUndo, true);
      expect(saver.hasRedo, false);

      rx.value = true;
      saver.undo();
      expect(saver.hasUndo, false);
      expect(saver.hasRedo, true);

      saver.redo();
      expect(saver.hasUndo, true);
      expect(saver.hasRedo, false);
    });
  });

  group('Action', () {
    test('redo callback is invoked by redo()', () {
      int redoCalled = 0;
      int undoCalled = 0;
      final action = Action(
        redo: () => redoCalled++,
        undo: () => undoCalled++,
      );

      action.redo();
      expect(redoCalled, 1);
      expect(undoCalled, 0);
    });

    test('undo callback is invoked by undo()', () {
      int undoCalled = 0;
      final action = Action(
        redo: () {},
        undo: () => undoCalled++,
      );

      action.undo();
      expect(undoCalled, 1);
    });

    test('redo and undo can be called multiple times', () {
      int redoCalled = 0;
      int undoCalled = 0;
      final action = Action(
        redo: () => redoCalled++,
        undo: () => undoCalled++,
      );

      action.redo();
      action.redo();
      action.undo();
      expect(redoCalled, 2);
      expect(undoCalled, 1);
    });
  });

  group('BlueprintTheme', () {
    test('dark factory produces correct background color', () {
      final theme = BlueprintTheme.dark();
      expect(theme.backgroundColor, const Color(0xFF212121));
    });

    test('dark factory has correct grid color', () {
      final theme = BlueprintTheme.dark();
      expect(theme.gridColor, const Color(0x1AFFFFFF));
      expect(theme.gridLineColor, const Color(0x1AFFFFFF));
    });

    test('dark factory has correct port colors', () {
      final theme = BlueprintTheme.dark();
      expect(theme.defaultPortInputColor, Colors.orange);
      expect(theme.defaultPortOutputColor, Colors.green);
    });

    test('dark factory has correct connection defaults', () {
      final theme = BlueprintTheme.dark();
      expect(theme.defaultConnectionColor, Colors.white);
      expect(theme.defaultConnectionStrokeWidth, 2.0);
    });

    test('dark factory has correct ruler colors', () {
      final theme = BlueprintTheme.dark();
      expect(theme.rulerTextColor, const Color(0x4DFFFFFF));
      expect(theme.rulerLineColor, const Color(0x33FFFFFF));
    });

    test('dark factory has correct size handle color', () {
      final theme = BlueprintTheme.dark();
      expect(theme.sizeHandleColor, Colors.white);
    });

    test('light factory produces correct background color', () {
      final theme = BlueprintTheme.light();
      expect(theme.backgroundColor, const Color(0xFFFAFAFA));
    });

    test('light factory has correct grid color', () {
      final theme = BlueprintTheme.light();
      expect(theme.gridColor, const Color(0x1A000000));
      expect(theme.gridLineColor, const Color(0x1A000000));
    });

    test('light factory has correct connection color', () {
      final theme = BlueprintTheme.light();
      expect(theme.defaultConnectionColor, Colors.black);
    });

    test('light factory has correct ruler colors', () {
      final theme = BlueprintTheme.light();
      expect(theme.rulerTextColor, const Color(0x4D000000));
      expect(theme.rulerLineColor, const Color(0x33000000));
    });

    test('light factory size handle is black87', () {
      final theme = BlueprintTheme.light();
      expect(theme.sizeHandleColor, Colors.black87);
    });

    test('copyWith overrides only the specified fields', () {
      final theme = BlueprintTheme.dark();
      final modified = theme.copyWith(
        backgroundColor: const Color(0xFF000000),
        defaultConnectionStrokeWidth: 4.0,
      );

      expect(modified.backgroundColor, const Color(0xFF000000));
      expect(modified.defaultConnectionStrokeWidth, 4.0);
      // Unchanged fields retain original values.
      expect(modified.gridColor.toARGB32(), theme.gridColor.toARGB32());
      expect(modified.defaultPortInputColor.toARGB32(), theme.defaultPortInputColor.toARGB32());
      expect(modified.rulerTextColor.toARGB32(), theme.rulerTextColor.toARGB32());
      expect(modified.sizeHandleColor.toARGB32(), theme.sizeHandleColor.toARGB32());
    });

    test('copyWith with no arguments returns equal theme', () {
      final theme = BlueprintTheme.dark();
      final copy = theme.copyWith();

      expect(copy.backgroundColor.toARGB32(), theme.backgroundColor.toARGB32());
      expect(copy.gridColor.toARGB32(), theme.gridColor.toARGB32());
      expect(copy.defaultConnectionStrokeWidth, theme.defaultConnectionStrokeWidth);
    });

    test('round-trip JSON serialization for dark theme', () {
      final theme = BlueprintTheme.dark();
      final json = theme.toJson();
      final restored = BlueprintTheme.fromJson(json);

      expect(restored.backgroundColor.toARGB32(), theme.backgroundColor.toARGB32());
      expect(restored.gridColor.toARGB32(), theme.gridColor.toARGB32());
      expect(restored.gridLineColor.toARGB32(), theme.gridLineColor.toARGB32());
      expect(restored.defaultPortInputColor.toARGB32(), theme.defaultPortInputColor.toARGB32());
      expect(restored.defaultPortOutputColor.toARGB32(), theme.defaultPortOutputColor.toARGB32());
      expect(restored.defaultConnectionColor.toARGB32(), theme.defaultConnectionColor.toARGB32());
      expect(restored.defaultConnectionStrokeWidth, theme.defaultConnectionStrokeWidth);
      expect(restored.rulerTextColor.toARGB32(), theme.rulerTextColor.toARGB32());
      expect(restored.rulerLineColor.toARGB32(), theme.rulerLineColor.toARGB32());
      expect(restored.sizeHandleColor.toARGB32(), theme.sizeHandleColor.toARGB32());
    });

    test('round-trip JSON serialization for light theme', () {
      final theme = BlueprintTheme.light();
      final json = theme.toJson();
      final restored = BlueprintTheme.fromJson(json);

      expect(restored.backgroundColor.toARGB32(), theme.backgroundColor.toARGB32());
      expect(restored.defaultConnectionColor.toARGB32(), theme.defaultConnectionColor.toARGB32());
    });

    test('fromJson uses default strokeWidth when not present', () {
      final theme = BlueprintTheme.dark();
      final json = theme.toJson();
      // Remove the optional field to test the default.
      json.remove('defaultConnectionStrokeWidth');
      final restored = BlueprintTheme.fromJson(json);
      expect(restored.defaultConnectionStrokeWidth, 2.0);
    });

    test('toJson contains all expected keys', () {
      final theme = BlueprintTheme.dark();
      final json = theme.toJson();

      expect(json, containsKey('backgroundColor'));
      expect(json, containsKey('gridColor'));
      expect(json, containsKey('gridLineColor'));
      expect(json, containsKey('defaultPortInputColor'));
      expect(json, containsKey('defaultPortOutputColor'));
      expect(json, containsKey('defaultConnectionColor'));
      expect(json, containsKey('defaultConnectionStrokeWidth'));
      expect(json, containsKey('rulerTextColor'));
      expect(json, containsKey('rulerLineColor'));
      expect(json, containsKey('sizeHandleColor'));
    });

    test('copyWith can update every field independently', () {
      final base = BlueprintTheme.dark();
      const newColor = Color(0xFFABCDEF);

      expect(base.copyWith(backgroundColor: newColor).backgroundColor, newColor);
      expect(base.copyWith(gridColor: newColor).gridColor, newColor);
      expect(base.copyWith(gridLineColor: newColor).gridLineColor, newColor);
      expect(base.copyWith(defaultPortInputColor: newColor).defaultPortInputColor, newColor);
      expect(base.copyWith(defaultPortOutputColor: newColor).defaultPortOutputColor, newColor);
      expect(base.copyWith(defaultConnectionColor: newColor).defaultConnectionColor, newColor);
      expect(base.copyWith(rulerTextColor: newColor).rulerTextColor, newColor);
      expect(base.copyWith(rulerLineColor: newColor).rulerLineColor, newColor);
      expect(base.copyWith(sizeHandleColor: newColor).sizeHandleColor, newColor);
      expect(base.copyWith(defaultConnectionStrokeWidth: 5.0).defaultConnectionStrokeWidth, 5.0);
    });
  });
}


