# Blueprint System 🗺️

A flutter library that creates blueprint widgets with <b>nodes</b> (child widgets) that may be added to them. These nodes can be <b>moved</b>, <b>resized</b>, and <b>modified</b>. ⚡

<!-- ## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package. -->

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
NodeController node = NodeController(
    initPosition: const Offset(30, 10),     // initial position
    initSize: const Size(200, 50),          // initial size
);

controller.addNode(node);
```

## Additional information

This package is still under development and I will do my best to make it more stable.
PRs are always welcome! 🦄
