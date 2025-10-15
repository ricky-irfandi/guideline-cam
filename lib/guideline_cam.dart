/// A Flutter package for camera capture with customizable guideline overlays.
///
/// This package provides a camera interface with overlay shapes (rectangle, rounded
/// rectangle, circle, oval) to guide users in capturing documents, IDs, or faces.
/// It supports both single and multi-shape overlays with advanced positioning options.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:guideline_cam/guideline_cam.dart';
///
/// class CapturePage extends StatefulWidget {
///   @override
///   _CapturePageState createState() => _CapturePageState();
/// }
///
/// class _CapturePageState extends State<CapturePage> {
///   late GuidelineCamController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = GuidelineCamController();
///     _controller.initialize();
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: GuidelineCamBuilder(
///         controller: _controller,
///         guideline: GuidelineOverlayConfig(
///           shape: GuidelineShape.roundedRect,
///           aspectRatio: 1.586, // ID card ratio
///         ),
///         onCapture: (result) {
///           // Handle captured image
///           print('Captured: ${result.file.path}');
///         },
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Key Features
///
/// * **Multiple Overlay Shapes**: Rectangle, rounded rectangle, circle, and oval
/// * **Aspect Ratio Control**: Maintain specific document proportions
/// * **Multi-Shape Support**: Complex overlays with nested shapes
/// * **Customizable Styling**: Colors, stroke width, corner indicators
/// * **Camera Controls**: Flash toggle, camera switching
/// * **Builder Pattern**: Customizable UI components
///
/// ## Main Components
///
/// * [GuidelineCamBuilder] - The main camera widget with overlay
/// * [GuidelineCamController] - Manages camera lifecycle and capture
/// * [GuidelineOverlayConfig] - Configuration for overlay appearance
/// * [ShapeConfig] - Individual shape configuration for multi-shape overlays
///
/// See also:
/// * [GuidelineCamBuilder], the main widget for camera capture
/// * [GuidelineCamController], for camera management
/// * [GuidelineOverlayConfig], for overlay customization
library;

export 'package:camera/camera.dart'
    show
        CameraController,
        CameraException,
        CameraLensDirection,
        FlashMode,
        XFile;

export 'src/config.dart';
export 'src/controller.dart';
export 'src/enums.dart';
export 'src/guideline_cam_view.dart';
export 'src/multi_shape_config.dart';
export 'src/results.dart';
