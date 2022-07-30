<div align="center">
  <a href="#">
    <img src="https://user-images.githubusercontent.com/35843293/181866140-cf4dfec6-31fb-4bb3-822c-24b871eb32c2.png" alt="Logo" width="80" height="80"/>
  </a>
  <h1>Blueprint System</h1>
  <p>
    A Flutter library that creates blueprint widgets with <b>nodes</b> (child widgets) that may be added to them. These nodes can be <b>moved</b>, <b>resized</b>, and <b>modified</b>.
  </p>
  <h3>
    <a href="https://salah-rashad.github.io/blueprint_system_docs" target="_blank" style="color: white">
      Explore the docs »
    </a>
  </h3>
  <a href="https://github.com/salah-rashad/blueprint_system/blob/master/example" target="_blank">
    View Example
  </a>
   · 
  <a href="https://github.com/salah-rashad/blueprint_system/issues/new?labels=bug&assignees=salah-rashad" target="_blank">
    Report Bug
  </a>
   · 
  <a href="https://github.com/salah-rashad/blueprint_system/issues/new?labels=feature&assignees=salah-rashad" target="_blank">
    Request Feature
  </a>
  <br/><br/>
  <a href="https://pub.dev/packages/blueprint_system" target="_blank">
    <img src="https://img.shields.io/pub/v/blueprint_system.svg?style=for-the-badge&label=pub&color=blue"/> 
  </a>
  <a href="https://github.com/salah-rashad/blueprint_system/blob/master/LICENSE" target="_blank">
    <img src="https://img.shields.io/github/license/salah-rashad/blueprint_system.svg?style=for-the-badge"/> 
  </a>
  <br/><br/>
</div>

![banner](assets/images/banner-1.png)

## Getting Started

### Installation

- ### Method 1 (Recommended)

  run this line in your terminal:

  ```bash
  flutter pub add blueprint_system
  ```

- ### Method 2

  add this line to your `pubspec.yaml` dependencies:

  ```yaml title="pubspec.yaml"
  dependencies:
    blueprint_system: 0.1.1
  ```

  then get packages, (Alternatively, your editor might support this)

  ```bash
  flutter pub get
  ```

### Quick Implementation
- #### Method 1 (using children)
  ```dart
  Blueprint(
    children: [
      FloatingNode(
        initPosition: Offset(300, 500),
        initSize: const Size(200, 100),
        child: (c) => Container(
          color: Colors.blue,
        ),
      ),
    ],
  );
  ```
- #### Method 2 (using a controller)
  1. Initialize controller and assign it to Blueprint widget  

      ```dart
      BlueprintController controller = BlueprintController.instance

      @override
      Widget build(BuildContext context) {
          return Scaffold(
              body: Blueprint(controller: controller),
          );
      }
      ```
  2. Control your blueprint anywhere in the project

      ```dart
      DraggableNode node = DraggableNode(
          initPosition: const Offset(50, 100),    // optional, default is (100, 100)
          initSize: const Size(200, 100),         // optional, default is (100, 100)
          child: (c) => Container(
              color: Colors.red,
              child: Text(c.position.toString()),
          ),
      );

      // add node(s)
      controller.addNode(node);
      // or
      controller.addNodes([node1, node2, ...]);
      ```
## Learn More

- More info: [Explore the docs](https://salah-rashad.github.io/blueprint_system_docs)
- See: [Full Example](https://github.com/salah-rashad/blueprint_system/blob/master/example)

## Known Issues
- Transferring a DraggableNode from a Blueprint to another.
  > _Explanation_: When dragging and dropping a DraggableNode in another Blueprint, a new node is created in the __second Blueprint__ with the same values (different id of course.), and simply removing the old DraggableNode from the __first Blueprint__, could make it lost in both blueprints forever if the transferring operation failed. So I need to think about a better solution for this.  
  
  Track this issue here [#2](https://github.com/salah-rashad/blueprint_system/issues/2)

## Additional Information

This package is still under development 🚧 and I will do my best to make it more stable.  
If you encounter any bugs, please **[file an issue](https://github.com/salah-rashad/blueprint_system/issues/new?labels=bug&assignees=salah-rashad)** and I will try to fix them as soon as possible.  
Pull requests are always welcome! 🦄

## // TODO:

- [x] Fixed Node 📌
- [x] Draggable Node 👆↔️
- [x] Floating Node ✨
- [x] Blueprint rulers 📏
- [ ] https://github.com/salah-rashad/blueprint_system/issues/2
- [ ] Connecting Nodes using arrows (like the flow chart).
- [ ] Implement Blueprint Export to JSON, YAML, XML, etc.
- [ ] Add the ability to resize nodes (visually not programmatically).
- [ ] Blueprint Themes/Templates.
- [ ] Add an option to make the `FloatingNode` responsive to screen size changes.