# Blueprint System 🗺️

A flutter library that creates blueprint widgets with <b>nodes</b> (child widgets) that may be added to them. These nodes can be <b>moved</b>, <b>resized</b>, and <b>modified</b>. ⚡<br/>

[![pub package](https://img.shields.io/pub/v/blueprint_system.svg?label=pub&color=blue)](https://pub.dev/packages/blueprint_system)

## Usage

1. Initialize controller _(required)_

```dart
BlueprintController controller = BlueprintController();
```

2. Use `Blueprint` widget and assign controller to it

```dart
@override
Widget build(BuildContext context) {
    return Scaffold(
        body: Blueprint(controller),
    );
}
```

3. Add your first node 🛹

```dart
DraggableNode node = DraggableNode(
    initPosition: const Offset(50, 100),    // optional, default: (100, 100)
    initSize: const Size(200, 100),         // optional, default: (100, 100)
    child: (c) => Container(
        color: Colors.red,
        child: Text(c.position.toString()),
    ),
);

controller.addNode(node);
// or
controller.addNodes([node1, node2, ...]);
```

See: [Example](https://pub.dev/packages/blueprint_system/example)

## //TODO:

- [ ] Blueprint Theme
- [ ] Blueprint rulers
- [ ] Blueprint Export to JSON, YAML, XML, etc.
- [ ] Floating Node ✨

## Additional information

This package is still under development and I will do my best to make it more stable.<br/>
_PRs are always welcome! 🦄
