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
  });
}

class _TestSaver with ActionsSaver {}
