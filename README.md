# 📸 GuidelineCamBuilder

A lightweight Flutter package that helps build guideline camera overlay to capture IDs, documents, or faces.
Supports **rectangles, rounded rectangles, circles, and ovals** for manual image capture.

---

## 🎬 Demo Gallery

|                                                                                  |                                                                  |                                                    |
| -------------------------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------- |
| **Basic Usage**                                                                  | **Custom Button**                                                | **Overlay Builder**                                |
| ![Basic Usage](snapshot/basic.gif)                                               | ![Custom Button](snapshot/custom%20button.gif)                   | ![Overlay Builder](snapshot/overlay%20builder.gif) |
| **Built-in Instruction Builder**                                                 | **Multi & Nested Shape**                                         |                                                    |
| ![Built-in Instruction Builder](snapshot/built%20in%20instruction%20builder.gif) | ![Multi & Nested Shape](snapshot/multi%20&%20nested%20shape.gif) |                                                    |

---

## 🚀 Quick Start

### 1. Install

```yaml
dependencies:
  guideline_cam: ^0.0.1
```

### 2. Add permissions

**Android** → `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** → `Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to the camera to capture your document/ID</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to the micrphone to capture your document/ID</string>
```

### 3. Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:guideline_cam/guideline_cam.dart';

class CapturePage extends StatefulWidget {
  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  late GuidelineCamController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GuidelineCamController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GuidelineCamBuilder Example")),
      body: GuidelineCamBuilder(
        controller: _controller,
        guideline: GuidelineOverlayConfig(
          shape: GuidelineShape.roundedRect,   // 👈 try GuidelineShape.circle
          aspectRatio: 3 / 2, // Width : height
          frameColor: Colors.green,
          maskColor: Colors.black54,
        ),
        flashButtonBuilder: (context, flashMode, onPressed) {
          return FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: flashMode == FlashMode.off ? Colors.red : Colors.green,
            child: Icon(flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on),
          );
        },
        cameraSwitchButtonBuilder: (context, lensDirection, onPressed) {
          return FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.blue,
            child: Icon(lensDirection == CameraLensDirection.back ? Icons.camera_front : Icons.camera_rear),
          );
        },
        onCapture: (result) {
          // Handle the captured image
          // result.file contains the captured image file
        },
      ),
    );
  }
}
```

---

## 🎨 Overlay Options

- **GuidelineShape.rect** → plain rectangle
- **GuidelineShape.roundedRect** → rectangle with border radius (default)
- **GuidelineShape.circle** → circle (ideal for face/biometric capture)
- **GuidelineShape.oval** → oval (e.g. passport photo frame)

---

⚡ Example: switch to a circle for face capture

```dart
guideline: GuidelineOverlayConfig(
  shape: GuidelineShape.circle,
  frameColor: Colors.blueAccent,
  maskColor: Colors.black54,
),
```

---

## 🎛️ Custom Button Builders

You can customize the flash toggle and camera switch buttons by providing your own builders:

```dart
GuidelineCamBuilder(
  controller: controller,
  guideline: const GuidelineOverlayConfig(),
  flashButtonBuilder: (context, flashMode, onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: flashMode == FlashMode.off ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  flashMode == FlashMode.off ? 'OFF' : 'ON',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
  cameraSwitchButtonBuilder: (context, lensDirection, onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      child: Icon(
        lensDirection == CameraLensDirection.back
            ? Icons.camera_front
            : Icons.camera_rear,
      ),
    );
  },
)
```

The builders receive:

- `context`: BuildContext for the widget
- `flashMode`/`lensDirection`: Current state for styling
- `onPressed`: Callback to trigger the action

If no custom builders are provided, default FloatingActionButton.small widgets are used.

### Complete Overlay Control

For maximum flexibility, you can provide a custom `overlayBuilder` to completely control the overlay layout:

```dart
GuidelineCamBuilder(
  controller: controller,
  guideline: const GuidelineOverlayConfig(),
  overlayBuilder: (context, controller) {
    return Stack(
      children: [
        // Custom positioned flash button
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            onPressed: () async {
              final currentMode = controller.flashMode;
              final newMode = currentMode == FlashMode.off
                  ? FlashMode.always
                  : FlashMode.off;
              await controller.setFlashMode(newMode);
            },
            backgroundColor: controller.flashMode == FlashMode.off
                ? Colors.red
                : Colors.green,
            child: Icon(controller.flashMode == FlashMode.off
                ? Icons.flash_off
                : Icons.flash_on),
          ),
        ),
        // Custom positioned camera switch button
        Positioned(
          bottom: 100,
          left: 20,
          child: FloatingActionButton(
            onPressed: () async {
              await controller.switchCamera();
            },
            backgroundColor: Colors.blue,
            child: Icon(controller.lensDirection == CameraLensDirection.back
                ? Icons.camera_front
                : Icons.camera_rear),
          ),
        ),
        // Custom capture button
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.large(
              onPressed: () async {
                final result = await controller.capture();
                // Handle result
              },
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ),
        // Custom status indicator
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'State: ${controller.state.name}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  },
)
```

The `overlayBuilder` receives:

- `context`: BuildContext for the widget
- `controller`: GuidelineCamController with all camera controls

When `overlayBuilder` is provided, it completely replaces the default overlay system, giving you full control over positioning, styling, and layout.

### Multi-Shape Overlays

For complex capture scenarios like ID cards with face photos, you can use multiple shapes in a single overlay:

```dart
GuidelineCamBuilder(
  controller: controller,
  guideline: GuidelineOverlayConfig(
    shapes: [
      // Face oval - top portion
      ShapeConfig(
        shape: GuidelineShape.oval,
        bounds: Rect.fromLTWH(50, 100, 200, 250),
        frameColor: Colors.blue,
        strokeWidth: 3.0,
        showGrid: true,
      ),
      // ID card rectangle - bottom portion
      ShapeConfig(
        shape: GuidelineShape.roundedRect,
        bounds: Rect.fromLTWH(20, 400, 300, 200),
        frameColor: Colors.green,
        strokeWidth: 3.0,
        borderRadius: 16.0,
        cornerLength: 30.0,
        showGrid: true,
      ),
    ],
    maskColor: Colors.black54,
  ),
)
```

The `ShapeConfig` class provides:

- `shape`: The type of shape (rect, roundedRect, circle, oval)
- `bounds`: Exact positioning and size using `Rect`
- `frameColor`: Color of the shape outline
- `strokeWidth`: Thickness of the outline
- `borderRadius`: Corner radius for rounded rectangles
- `cornerLength`: Length of corner indicators
- `showGrid`: Whether to show a 3x3 grid inside the shape

Multi-shape overlays provide a unified mask covering the entire screen except the defined shapes, making it perfect for complex document capture scenarios.

### Nested Shapes (Parent-Child Relationships)

For even more complex scenarios, you can create nested shapes where child shapes are positioned relative to their parent. This is perfect for ID cards with photo areas, signature sections, or any document with multiple distinct regions.

```dart
GuidelineCamBuilder(
  controller: controller,
  guideline: GuidelineOverlayConfig(
    shapes: [
      // Parent shape - ID card frame
      ShapeConfig(
        shape: GuidelineShape.roundedRect,
        bounds: Rect.fromLTWH(50, 100, 300, 400),
        frameColor: Colors.green,
        strokeWidth: 3.0,
        borderRadius: 16.0,
        children: [
          // Child 1: Centered photo area
          ShapeConfig.centered(
            shape: GuidelineShape.rect,
            size: Size(80, 100), // Absolute size
            frameColor: Colors.white,
            strokeWidth: 2.0,
          ),
          // Child 2: Relative positioned signature area
          ShapeConfig.relativePosition(
            shape: GuidelineShape.rect,
            relativeOffset: Offset(0.7, 0.8), // 70% right, 80% down
            size: Size(0.4, 0.15), // 40% of parent width, 15% of parent height
            frameColor: Colors.blue,
            strokeWidth: 2.0,
          ),
          // Child 3: Inset positioned text area
          ShapeConfig.inset(
            shape: GuidelineShape.rect,
            insets: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
            size: Size(0.6, 0.3), // 60% of parent width, 30% of parent height
            frameColor: Colors.orange,
            strokeWidth: 1.5,
          ),
        ],
      ),
    ],
  ),
)
```

#### Positioning Modes

- **`ShapePositioning.absolute`**: Uses fixed coordinates (default behavior)
- **`ShapePositioning.center`**: Automatically centers the child within the parent
- **`ShapePositioning.relative`**: Positions using percentage offsets (0.0 to 1.0)
- **`ShapePositioning.inset`**: Positions with pixel offsets from parent edges

#### Size Options

- **Absolute size**: `Size(100, 150)` - fixed pixel dimensions
- **Relative size**: `Size(0.3, 0.4)` - percentage of parent (30% width, 40% height)

#### Convenience Constructors

- `ShapeConfig.centered()` - Creates a centered child shape
- `ShapeConfig.inset()` - Creates a child with inset positioning
- `ShapeConfig.relativePosition()` - Creates a child with relative positioning

Nested shapes support unlimited depth - children can have their own children, creating complex hierarchical layouts.

---

## Troubleshooting

- **Flash not supported**: The flash toggle will be hidden if the device does not support it.
- **Focus tips**: Tap on the screen to focus on a specific area.

---

## 📚 API Reference

### GuidelineCamBuilder

```dart
GuidelineCamBuilder({
  required GuidelineCamController controller,
  GuidelineOverlayConfig guideline = const GuidelineOverlayConfig(),
  bool showFlashToggle = true,
  bool showCameraSwitch = true,
  Widget Function(BuildContext, GuidelineState)? instructionBuilder,
  Widget Function(BuildContext, FlashMode, VoidCallback)? flashButtonBuilder,
  Widget Function(BuildContext, CameraLensDirection, VoidCallback)? cameraSwitchButtonBuilder,
  Widget Function(BuildContext, GuidelineCamController)? overlayBuilder,
  void Function(GuidelineCaptureResult)? onCapture,
  void Function(Object, StackTrace)? onError,
})
```

| Parameter                 | Type                                                             | Required | Default                        | Description                                            |
| ------------------------- | ---------------------------------------------------------------- | -------- | ------------------------------ | ------------------------------------------------------ |
| controller                | GuidelineCamController                                           | Yes      | -                              | Controls camera lifecycle, state, and actions.         |
| guideline                 | GuidelineOverlayConfig                                           | No       | const GuidelineOverlayConfig() | Overlay config; supports single or multi-shape.        |
| showFlashToggle           | bool                                                             | No       | true                           | Show the default flash toggle button.                  |
| showCameraSwitch          | bool                                                             | No       | true                           | Show the default camera switch button.                 |
| instructionBuilder        | Widget Function(BuildContext, GuidelineState)                    | No       | -                              | Custom instruction widget renderer.                    |
| flashButtonBuilder        | Widget Function(BuildContext, FlashMode, VoidCallback)           | No       | -                              | Custom flash button (UI + action).                     |
| cameraSwitchButtonBuilder | Widget Function(BuildContext, CameraLensDirection, VoidCallback) | No       | -                              | Custom camera switch button.                           |
| overlayBuilder            | Widget Function(BuildContext, GuidelineCamController)            | No       | -                              | Full-control overlay; replaces defaults when provided. |
| onCapture                 | void Function(GuidelineCaptureResult)                            | No       | -                              | Called after a successful capture.                     |
| onError                   | void Function(Object, StackTrace)                                | No       | -                              | Called when an error occurs.                           |

### GuidelineCamController

| Member           | Type/Signature               | Description                                          |
| ---------------- | ---------------------------- | ---------------------------------------------------- |
| initialize       | Future<void>()               | Initializes the camera and updates state.            |
| dispose          | void                         | Releases resources.                                  |
| capture          | Future<XFile?>()             | Takes a photo; returns `XFile` or null if not ready. |
| switchCamera     | Future<void>()               | Toggles between front and back cameras.              |
| setFlashMode     | Future<void>(FlashMode mode) | Sets the flash mode.                                 |
| cameraController | CameraController?            | Underlying `camera` controller (read-only).          |
| state            | GuidelineState               | Current state (read-only).                           |
| stateStream      | Stream<GuidelineState>       | Emits state changes.                                 |
| flashMode        | FlashMode                    | Current flash mode (read-only).                      |
| lensDirection    | CameraLensDirection          | Current lens direction (read-only).                  |

### GuidelineOverlayConfig

```dart
const GuidelineOverlayConfig({
  GuidelineShape shape = GuidelineShape.roundedRect,
  double? aspectRatio = 1.586,
  double strokeWidth = 2.0,
  double borderRadius = 12.0,
  Color maskColor = Colors.black54,
  Color frameColor = Colors.white,
  double cornerLength = 20.0,
  EdgeInsets padding = const EdgeInsets.all(20.0),
  bool showGrid = false,
  bool debugPaint = false,
  List<ShapeConfig>? shapes,
})
```

| Parameter    | Type               | Required | Default                    | Description                                |
| ------------ | ------------------ | -------- | -------------------------- | ------------------------------------------ |
| shape        | GuidelineShape     | No       | GuidelineShape.roundedRect | Shape for single-shape overlays.           |
| aspectRatio  | double?            | No       | 1.586                      | Frame aspect ratio; must be > 0 when set.  |
| strokeWidth  | double             | No       | 2.0                        | Outline thickness.                         |
| borderRadius | double             | No       | 12.0                       | Corner radius for rounded rectangles.      |
| maskColor    | Color              | No       | Colors.black54             | Mask color outside the frame.              |
| frameColor   | Color              | No       | Colors.white               | Frame color.                               |
| cornerLength | double             | No       | 20.0                       | Corner indicator length.                   |
| padding      | EdgeInsets         | No       | EdgeInsets.all(20.0)       | Padding around the overlay.                |
| showGrid     | bool               | No       | false                      | Show 3x3 grid.                             |
| debugPaint   | bool               | No       | false                      | Paint debug visuals.                       |
| shapes       | List<ShapeConfig>? | No       | null                       | Enables multi-shape overlay when provided. |

| Helper             | Type/Signature           | Description                                     |
| ------------------ | ------------------------ | ----------------------------------------------- |
| isMultiShape       | bool getter              | True when `shapes` is non-empty.                |
| toMultiShapeConfig | MultiShapeOverlayConfig? | Converts to multi-shape config when applicable. |

### Multi-shape overlay types

#### ShapeConfig

```dart
const ShapeConfig({
  required GuidelineShape shape,
  required Rect bounds,
  double? aspectRatio,
  double strokeWidth = 2.0,
  double borderRadius = 12.0,
  Color frameColor = Colors.white,
  double cornerLength = 20.0,
  bool showGrid = false,
  List<ShapeConfig>? children,
  ShapePositioning positioning = ShapePositioning.absolute,
  Offset? relativeOffset,
  EdgeInsets? insets,
  Size? size,
})
```

| Parameter      | Type               | Required | Default                   | Description                                 |
| -------------- | ------------------ | -------- | ------------------------- | ------------------------------------------- |
| shape          | GuidelineShape     | Yes      | -                         | Shape type.                                 |
| bounds         | Rect               | Yes      | -                         | Bounds of the shape within the overlay.     |
| aspectRatio    | double?            | No       | null                      | Optional aspect ratio for supported shapes. |
| strokeWidth    | double             | No       | 2.0                       | Shape outline thickness.                    |
| borderRadius   | double             | No       | 12.0                      | Corner radius for rounded rectangles.       |
| frameColor     | Color              | No       | Colors.white              | Outline color.                              |
| cornerLength   | double             | No       | 20.0                      | Corner indicator length.                    |
| showGrid       | bool               | No       | false                     | Show 3x3 grid inside the shape.             |
| children       | List<ShapeConfig>? | No       | null                      | Optional child shapes.                      |
| positioning    | ShapePositioning   | No       | ShapePositioning.absolute | Child positioning mode.                     |
| relativeOffset | Offset?            | No       | null                      | Used with `relative` positioning (0.0–1.0). |
| insets         | EdgeInsets?        | No       | null                      | Used with `inset` positioning.              |
| size           | Size?              | No       | null                      | Absolute or relative size (0.0–1.0).        |

| Factory          | Signature                           | Description                                    |
| ---------------- | ----------------------------------- | ---------------------------------------------- |
| withValidation   | ShapeConfig.withValidation({...})   | Adds assertions for relative values/sizes.     |
| centered         | ShapeConfig.centered({...})         | Creates centered child with explicit size.     |
| inset            | ShapeConfig.inset({...})            | Positions child with insets from parent edges. |
| relativePosition | ShapeConfig.relativePosition({...}) | Positions child with relative offsets.         |

| Method   | Signature                   | Description              |
| -------- | --------------------------- | ------------------------ |
| copyWith | ShapeConfig copyWith({...}) | Returns a modified copy. |

#### MultiShapeOverlayConfig

```dart
MultiShapeOverlayConfig({
  required List<ShapeConfig> shapes,
  Color maskColor = Colors.black54,
  bool debugPaint = false,
})
```

| Parameter  | Type              | Required | Default        | Description                      |
| ---------- | ----------------- | -------- | -------------- | -------------------------------- |
| shapes     | List<ShapeConfig> | Yes      | -              | Shapes to render in the overlay. |
| maskColor  | Color             | No       | Colors.black54 | Mask color outside all shapes.   |
| debugPaint | bool              | No       | false          | Paint debug visuals.             |

| Method   | Signature                               | Description              |
| -------- | --------------------------------------- | ------------------------ |
| copyWith | MultiShapeOverlayConfig copyWith({...}) | Returns a modified copy. |

### Enums

- `GuidelineShape`: `rect`, `roundedRect`, `circle`, `oval`
- `GuidelineState`: `initializing`, `ready`, `capturing`, `error`
- `ShapePositioning`: `absolute`, `relative`, `center`, `inset`

### Capture Result

| Field      | Type                | Description                |
| ---------- | ------------------- | -------------------------- |
| file       | XFile               | Captured image file.       |
| capturedAt | DateTime            | Timestamp of capture.      |
| lens       | CameraLensDirection | Lens used for the capture. |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Issues

If you encounter any issues or have suggestions, please file them in the [GitHub Issues](https://github.com/ricky-irfandi/guideline-cam/issues).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed changelog.

---

Made with ❤️ by [Ricky-Irfandi](https://github.com/ricky-irfandi)
