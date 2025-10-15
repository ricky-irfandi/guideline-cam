import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:guideline_cam/src/config.dart';
import 'package:guideline_cam/src/controller.dart';
import 'package:guideline_cam/src/enums.dart';
import 'package:guideline_cam/src/multi_shape_painter.dart';
import 'package:guideline_cam/src/overlay_painter.dart';
import 'package:guideline_cam/src/results.dart';

/// A widget that displays a camera preview with a customizable guideline overlay.
///
/// This widget provides a complete camera interface with overlay shapes
/// (rectangle, rounded rectangle, circle, oval) to guide users in capturing
/// documents, IDs, or faces. It supports both single and multi-shape overlays
/// with extensive customization options.
///
/// ## Basic Usage
///
/// ```dart
/// class DocumentCapturePage extends StatefulWidget {
///   @override
///   _DocumentCapturePageState createState() => _DocumentCapturePageState();
/// }
///
/// class _DocumentCapturePageState extends State<DocumentCapturePage> {
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
///       appBar: AppBar(title: Text('Capture Document')),
///       body: GuidelineCamBuilder(
///         controller: _controller,
///         guideline: GuidelineOverlayConfig(
///           shape: GuidelineShape.roundedRect,
///           aspectRatio: 1.586, // ID card ratio
///           frameColor: Colors.white,
///           maskColor: Colors.black54,
///         ),
///         onCapture: (result) {
///           // Handle captured image
///           Navigator.push(
///             context,
///             MaterialPageRoute(
///               builder: (context) => ImagePreviewPage(result.file),
///             ),
///           );
///         },
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Custom UI with Builder Pattern
///
/// ```dart
/// GuidelineCamBuilder(
///   controller: _controller,
///   guideline: GuidelineOverlayConfig(
///     shape: GuidelineShape.circle,
///     frameColor: Colors.blue,
///   ),
///   // Custom flash button
///   flashButtonBuilder: (context, flashMode, onPressed) {
///     return Positioned(
///       top: 50,
///       right: 20,
///       child: IconButton(
///         onPressed: onPressed,
///         icon: Icon(
///           flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
///           color: Colors.white,
///         ),
///       ),
///     );
///   },
///   // Custom camera switch button
///   cameraSwitchButtonBuilder: (context, lensDirection, onPressed) {
///     return Positioned(
///       top: 50,
///       left: 20,
///       child: IconButton(
///         onPressed: onPressed,
///         icon: Icon(
///           lensDirection == CameraLensDirection.back
///               ? Icons.camera_front
///               : Icons.camera_rear,
///           color: Colors.white,
///         ),
///       ),
///     );
///   },
///   // Custom instruction overlay
///   instructionBuilder: (context, state) {
///     return Container(
///       padding: EdgeInsets.all(16),
///       decoration: BoxDecoration(
///         color: Colors.black54,
///         borderRadius: BorderRadius.circular(8),
///       ),
///       child: Text(
///         'Position your face within the circle',
///         style: TextStyle(color: Colors.white),
///       ),
///     );
///   },
///   // Custom overlay with capture button
///   overlayBuilder: (context, controller) {
///     return Positioned(
///       bottom: 50,
///       left: 0,
///       right: 0,
///       child: Center(
///         child: FloatingActionButton.large(
///           onPressed: () async {
///             final result = await controller.capture();
///             if (result != null) {
///               // Handle capture
///             }
///           },
///           child: Icon(Icons.camera_alt),
///         ),
///       ),
///     );
///   },
/// )
/// ```
///
/// ## Multi-Shape Overlay
///
/// ```dart
/// GuidelineCamBuilder(
///   controller: _controller,
///   guideline: GuidelineOverlayConfig(
///     shapes: [
///       // Main document area
///       ShapeConfig(
///         shape: GuidelineShape.roundedRect,
///         bounds: Rect.fromLTWH(50, 100, 300, 200),
///         aspectRatio: 1.5,
///         frameColor: Colors.white,
///       ),
///       // Signature area
///       ShapeConfig.inset(
///         shape: GuidelineShape.rect,
///         insets: EdgeInsets.only(bottom: 20, right: 20),
///         size: Size(0.3, 0.2), // 30% width, 20% height of parent
///         frameColor: Colors.yellow,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// See also:
/// * [GuidelineCamController], for camera management
/// * [GuidelineOverlayConfig], for overlay configuration
/// * [ShapeConfig], for multi-shape overlays
class GuidelineCamBuilder extends StatefulWidget {
  const GuidelineCamBuilder({
    super.key,
    required this.controller,
    this.guideline = const GuidelineOverlayConfig(),
    this.showFlashToggle = true,
    this.showCameraSwitch = true,
    this.instructionBuilder,
    this.flashButtonBuilder,
    this.cameraSwitchButtonBuilder,
    this.overlayBuilder,
    this.onCapture,
    this.onError,
  });

  /// The controller that manages the camera lifecycle and capture functionality.
  ///
  /// This controller must be initialized before the widget can display the camera
  /// preview. It handles camera setup, state management, and image capture.
  ///
  /// Example:
  /// ```dart
  /// final controller = GuidelineCamController();
  /// await controller.initialize();
  /// ```
  ///
  /// See also:
  /// * [GuidelineCamController], for controller management
  final GuidelineCamController controller;

  /// The configuration for the guideline overlay appearance and behavior.
  ///
  /// This configuration determines the shape, size, colors, and other visual
  /// properties of the overlay that guides users during image capture.
  ///
  /// Example:
  /// ```dart
  /// guideline: GuidelineOverlayConfig(
  ///   shape: GuidelineShape.roundedRect,
  ///   aspectRatio: 1.586, // ID card ratio
  ///   frameColor: Colors.white,
  ///   maskColor: Colors.black54,
  ///   strokeWidth: 2.0,
  /// )
  /// ```
  ///
  /// See also:
  /// * [GuidelineOverlayConfig], for configuration options
  final GuidelineOverlayConfig guideline;

  /// Whether to display the default flash toggle button.
  ///
  /// When `true` (default), a flash toggle button is automatically positioned
  /// in the top-right corner. When `false`, no flash button is shown unless
  /// you provide a custom one via [flashButtonBuilder].
  ///
  /// Example:
  /// ```dart
  /// showFlashToggle: false, // Hide default flash button
  /// flashButtonBuilder: (context, flashMode, onPressed) {
  ///   // Custom flash button implementation
  ///   return MyCustomFlashButton(...);
  /// },
  /// ```
  final bool showFlashToggle;

  /// Whether to display the default camera switch button.
  ///
  /// When `true` (default), a camera switch button is automatically positioned
  /// in the top-left corner. When `false`, no switch button is shown unless
  /// you provide a custom one via [cameraSwitchButtonBuilder].
  ///
  /// Example:
  /// ```dart
  /// showCameraSwitch: false, // Hide default switch button
  /// cameraSwitchButtonBuilder: (context, lensDirection, onPressed) {
  ///   // Custom camera switch button implementation
  ///   return MyCustomSwitchButton(...);
  /// },
  /// ```
  final bool showCameraSwitch;

  /// A builder function for creating custom instruction widgets.
  ///
  /// This builder is called whenever the camera state changes, allowing you
  /// to display contextual instructions to the user. The widget is positioned
  /// at the bottom of the screen with left and right margins.
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [state] - The current camera state
  ///
  /// Example:
  /// ```dart
  /// instructionBuilder: (context, state) {
  ///   String message;
  ///   switch (state) {
  ///     case GuidelineState.initializing:
  ///       message = 'Initializing camera...';
  ///       break;
  ///     case GuidelineState.ready:
  ///       message = 'Position document within the frame';
  ///       break;
  ///     case GuidelineState.capturing:
  ///       message = 'Capturing image...';
  ///       break;
  ///     case GuidelineState.error:
  ///       message = 'Camera error occurred';
  ///       break;
  ///   }
  ///   return Container(
  ///     padding: EdgeInsets.all(16),
  ///     decoration: BoxDecoration(
  ///       color: Colors.black54,
  ///       borderRadius: BorderRadius.circular(8),
  ///     ),
  ///     child: Text(message, style: TextStyle(color: Colors.white)),
  ///   );
  /// },
  /// ```
  ///
  /// See also:
  /// * [GuidelineState], for available states
  final Widget Function(BuildContext, GuidelineState)? instructionBuilder;

  /// A builder function for creating custom flash toggle buttons.
  ///
  /// This builder provides complete control over the flash button appearance
  /// and behavior. It receives the current flash mode and a callback to toggle it.
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [flashMode] - The current flash mode setting
  /// * [onPressed] - Callback to toggle the flash mode
  ///
  /// Example:
  /// ```dart
  /// flashButtonBuilder: (context, flashMode, onPressed) {
  ///   return Positioned(
  ///     top: 50,
  ///     right: 20,
  ///     child: IconButton(
  ///       onPressed: onPressed,
  ///       icon: Icon(
  ///         flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
  ///         color: Colors.white,
  ///         size: 30,
  ///       ),
  ///       style: IconButton.styleFrom(
  ///         backgroundColor: Colors.black54,
  ///         shape: CircleBorder(),
  ///       ),
  ///     ),
  ///   );
  /// },
  /// ```
  ///
  /// See also:
  /// * [FlashMode], for available flash modes
  /// * [showFlashToggle], to control default button visibility
  final Widget Function(BuildContext, FlashMode, VoidCallback)?
      flashButtonBuilder;

  /// A builder function for creating custom camera switch buttons.
  ///
  /// This builder provides complete control over the camera switch button
  /// appearance and behavior. It receives the current lens direction and a
  /// callback to switch cameras.
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [lensDirection] - The current camera lens direction
  /// * [onPressed] - Callback to switch between front and back cameras
  ///
  /// Example:
  /// ```dart
  /// cameraSwitchButtonBuilder: (context, lensDirection, onPressed) {
  ///   return Positioned(
  ///     top: 50,
  ///     left: 20,
  ///     child: IconButton(
  ///       onPressed: onPressed,
  ///       icon: Icon(
  ///         lensDirection == CameraLensDirection.back
  ///             ? Icons.camera_front
  ///             : Icons.camera_rear,
  ///         color: Colors.white,
  ///         size: 30,
  ///       ),
  ///       style: IconButton.styleFrom(
  ///         backgroundColor: Colors.black54,
  ///         shape: CircleBorder(),
  ///       ),
  ///     ),
  ///   );
  /// },
  /// ```
  ///
  /// See also:
  /// * [CameraLensDirection], for available lens directions
  /// * [showCameraSwitch], to control default button visibility
  final Widget Function(BuildContext, CameraLensDirection, VoidCallback)?
      cameraSwitchButtonBuilder;

  /// A builder function for creating custom overlay widgets.
  ///
  /// This builder provides complete control over the overlay layout, allowing
  /// you to add custom buttons, indicators, or any other widgets on top of
  /// the camera preview. When provided, this overrides the default overlay
  /// (flash button, camera switch button, instructions).
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [controller] - The camera controller for accessing camera functionality
  ///
  /// Example:
  /// ```dart
  /// overlayBuilder: (context, controller) {
  ///   return Stack(
  ///     children: [
  ///       // Custom capture button
  ///       Positioned(
  ///         bottom: 50,
  ///         left: 0,
  ///         right: 0,
  ///         child: Center(
  ///           child: FloatingActionButton.large(
  ///             onPressed: () async {
  ///               final result = await controller.capture();
  ///               if (result != null) {
  ///                 // Handle capture
  ///               }
  ///             },
  ///             child: Icon(Icons.camera_alt),
  ///           ),
  ///         ),
  ///       ),
  ///       // Custom flash button
  ///       Positioned(
  ///         top: 50,
  ///         right: 20,
  ///         child: MyCustomFlashButton(controller: controller),
  ///       ),
  ///     ],
  ///   );
  /// },
  /// ```
  ///
  /// See also:
  /// * [GuidelineCamController], for controller functionality
  final Widget Function(BuildContext, GuidelineCamController)? overlayBuilder;

  /// A callback function that is called when an image is successfully captured.
  ///
  /// This callback receives a [GuidelineCaptureResult] containing the captured
  /// image file, timestamp, and camera information. Use this to process or
  /// save the captured image.
  ///
  /// Parameters:
  /// * [result] - The capture result containing the image file and metadata
  ///
  /// Example:
  /// ```dart
  /// onCapture: (result) {
  ///   print('Image captured at: ${result.capturedAt}');
  ///   print('Camera lens: ${result.lens}');
  ///   print('File path: ${result.file.path}');
  ///
  ///   // Save to gallery
  ///   GallerySaver.saveImage(result.file.path);
  ///
  ///   // Navigate to preview
  ///   Navigator.push(
  ///     context,
  ///     MaterialPageRoute(
  ///       builder: (context) => ImagePreviewPage(result.file),
  ///     ),
  ///   );
  /// },
  /// ```
  ///
  /// See also:
  /// * [GuidelineCaptureResult], for result structure
  final void Function(GuidelineCaptureResult)? onCapture;

  /// A callback function that is called when an error occurs during camera operations.
  ///
  /// This callback receives the error object and stack trace, allowing you to
  /// handle camera errors gracefully. Common errors include camera permission
  /// issues, hardware failures, or initialization problems.
  ///
  /// Parameters:
  /// * [error] - The error that occurred
  /// * [stackTrace] - The stack trace of the error
  ///
  /// Example:
  /// ```dart
  /// onError: (error, stackTrace) {
  ///   print('Camera error: $error');
  ///
  ///   if (error is CameraException) {
  ///     switch (error.code) {
  ///       case 'CameraAccessDenied':
  ///         // Show permission request dialog
  ///         _showPermissionDialog();
  ///         break;
  ///       case 'NoCamerasAvailable':
  ///         // Show no camera available message
  ///         _showNoCameraMessage();
  ///         break;
  ///       default:
  ///         // Show generic error message
  ///         ScaffoldMessenger.of(context).showSnackBar(
  ///           SnackBar(content: Text('Camera error: ${error.description}')),
  ///         );
  ///     }
  ///   }
  /// },
  /// ```
  ///
  /// See also:
  /// * [CameraException], for camera-specific errors
  final void Function(Object, StackTrace)? onError;

  @override
  State<GuidelineCamBuilder> createState() => _GuidelineCamBuilderState();
}

class _GuidelineCamBuilderState extends State<GuidelineCamBuilder> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller.cameraController != null &&
            widget.controller.cameraController!.value.isInitialized
        ? Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(widget.controller.cameraController!),
              _buildOverlay(),
              // Custom overlay builder - gives complete control
              if (widget.overlayBuilder != null)
                widget.overlayBuilder!(context, widget.controller)
              else
                // Default overlay with positioned buttons
                ..._buildDefaultOverlay(context),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  List<Widget> _buildDefaultOverlay(BuildContext context) {
    return [
      // Flash toggle button
      if (widget.showFlashToggle)
        Positioned(
          top: 50,
          right: 20,
          child: widget.flashButtonBuilder != null
              ? widget.flashButtonBuilder!(
                  context,
                  widget.controller.flashMode,
                  () async {
                    final currentMode = widget.controller.flashMode;
                    final newMode = currentMode == FlashMode.off
                        ? FlashMode.always
                        : FlashMode.off;
                    await widget.controller.setFlashMode(newMode);
                  },
                )
              : FloatingActionButton.small(
                  onPressed: () async {
                    final currentMode = widget.controller.flashMode;
                    final newMode = currentMode == FlashMode.off
                        ? FlashMode.always
                        : FlashMode.off;
                    await widget.controller.setFlashMode(newMode);
                  },
                  backgroundColor: widget.controller.flashMode == FlashMode.off
                      ? Colors.black54
                      : Colors.amber,
                  child: Icon(
                    widget.controller.flashMode == FlashMode.off
                        ? Icons.flash_off
                        : Icons.flash_on,
                    color: Colors.white,
                  ),
                ),
        ),
      // Camera switch button
      if (widget.showCameraSwitch)
        Positioned(
          top: 50,
          left: 20,
          child: widget.cameraSwitchButtonBuilder != null
              ? widget.cameraSwitchButtonBuilder!(
                  context,
                  widget.controller.lensDirection,
                  () async {
                    await widget.controller.switchCamera();
                  },
                )
              : FloatingActionButton.small(
                  onPressed: () async {
                    await widget.controller.switchCamera();
                  },
                  backgroundColor: Colors.black54,
                  child: const Icon(
                    Icons.switch_camera,
                    color: Colors.white,
                  ),
                ),
        ),
      // Instruction builder
      if (widget.instructionBuilder != null)
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: widget.instructionBuilder!(context, widget.controller.state),
        ),
    ];
  }

  Widget _buildOverlay() {
    // Check if this is a multi-shape configuration
    if (widget.guideline.isMultiShape) {
      final multiShapeConfig = widget.guideline.toMultiShapeConfig();
      if (multiShapeConfig != null) {
        return CustomPaint(
          painter: MultiShapeOverlayPainter(multiShapeConfig),
        );
      }
    }

    // Fall back to single shape overlay
    return CustomPaint(
      painter: OverlayPainter(widget.guideline),
    );
  }
}
