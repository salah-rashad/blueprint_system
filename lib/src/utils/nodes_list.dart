import 'dart:collection';

import '../widgets/node/node.dart';



class NodesList extends ListBase<Node> {
  NodesList();
  final List<Node> _innerList = [];

  @override
  set length(int value) {
    _innerList.length = value;
  }

  @override
  int get length => _innerList.length;

  @override
  Node operator [](int index) => _innerList[index];

  @override
  void operator []=(int index, Node value) {
    _innerList[index] = value;
  }

  factory NodesList.empty({bool growable = false}) => NodesList();
}
