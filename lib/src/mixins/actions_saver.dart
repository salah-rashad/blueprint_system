import 'package:get/get.dart';

/// A mixin that provides undo/redo support for reactive state changes.
///
/// Uses a simple change-stack pattern to record state mutations
/// and allow them to be undone or redone.
mixin ActionsSaver {
  final List<Action> _undoStack = [];
  final List<Action> _redoStack = [];

  int get canUndo => _undoStack.length;
  int get canRedo => _redoStack.length;

  bool get hasUndo => _undoStack.isNotEmpty;
  bool get hasRedo => _redoStack.isNotEmpty;

  /// Save a single value change for undo/redo.
  void saveAction<R>(Rx<R> rx, R newValue, [R? oldValue]) {
    final old = oldValue ?? rx.value;
    _undoStack.add(Action(
      redo: () => rx.value = newValue,
      undo: () => rx.value = old,
    ));
    _redoStack.clear();
  }

  /// Save a group of changes that should be undone/redone together.
  void saveActionGroup(List<Action> actions) {
    if (actions.isEmpty) return;
    _undoStack.addAll(actions);
    _redoStack.clear();
  }

  /// Undo the last action.
  void undo() {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    action.undo();
    _redoStack.add(action);
  }

  /// Redo the last undone action.
  void redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    action.redo();
    _undoStack.add(action);
  }

  /// Clear all undo/redo history.
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

class Action {
  final void Function() redo;
  final void Function() undo;

  Action({
    required this.redo,
    required this.undo,
  });
}
