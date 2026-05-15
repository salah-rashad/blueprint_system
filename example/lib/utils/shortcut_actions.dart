import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UndoAction extends SingleActivator {
  UndoAction() : super(LogicalKeyboardKey.keyZ, control: true);
}

class RedoAction extends SingleActivator {
  RedoAction() : super(LogicalKeyboardKey.keyZ, control: true, shift: true);
}
