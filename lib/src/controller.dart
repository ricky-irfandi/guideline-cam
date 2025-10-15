import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:guideline_cam/src/enums.dart';

/// A controller for the [GuidelineCamBuilder] widget.
///
/// This controller manages the camera lifecycle, state, and capture functionality.
/// It provides methods to initialize the camera, capture images, switch cameras,
/// and control flash settings.
///
/// ## Lifecycle
///
/// The controller follows this lifecycle:
/// 1. **Initialization**: Call [initialize()] to set up the camera
/// 2. **Ready State**: Camera is ready for capture operations
/// 3. **Capture**: Use [capture()] to take photos
/// 4. **Disposal**: Call [dispose()] to clean up resources
///
/// ## State Management
///
/// The controller notifies listeners of state changes through:
/// * [state] - Current state of the controller
/// * [stateStream] - Stream of state changes
/// * [ChangeNotifier.notifyListeners] - For UI updates
///
/// ## Example Usage
///
/// ```dart
/// class CameraPage extends StatefulWidget {
///   @override
///   _CameraPageState createState() => _CameraPageState();
/// }
///
/// class _CameraPageState extends State<CameraPage> {
///   late GuidelineCamController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = GuidelineCamController();
///     _controller.addListener(_onControllerStateChanged);
///     _initializeCamera();
///   }
///
///   void _onControllerStateChanged() {
///     if (_controller.state == GuidelineState.error) {
///       // Handle error state
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('Camera error occurred')),
///       );
///     }
///   }
///
///   Future<void> _initializeCamera() async {
///     try {
///       await _controller.initialize();
///     } catch (e) {
///       // Handle initialization error
///       print('Failed to initialize camera: $e');
///     }
///   }
///
///   Future<void> _captureImage() async {
///     try {
///       final result = await _controller.capture();
///       if (result != null) {
///         // Process captured image
///         print('Image captured: ${result.path}');
///       }
///     } catch (e) {
///       // Handle capture error
///       print('Failed to capture image: $e');
///     }
///   }
///
///   @override
///   void dispose() {
///     _controller.removeListener(_onControllerStateChanged);
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return GuidelineCamBuilder(
///       controller: _controller,
///       onCapture: (result) {
///         // Handle capture result
///         print('Captured at: ${result.capturedAt}');
///       },
///     );
///   }
/// }
/// ```
///
/// See also:
/// * [GuidelineCamBuilder], the widget that uses this controller
/// * [GuidelineState], for available states
/// * [GuidelineCaptureResult], for capture results
class GuidelineCamController extends ChangeNotifier {
  /// The underlying camera controller.
  CameraController? _cameraController;

  /// The current state of the controller.
  GuidelineState _state = GuidelineState.initializing;

  /// A stream of guideline states.
  final StreamController<GuidelineState> _stateStreamController =
      StreamController.broadcast();

  /// The current flash mode.
  FlashMode _flashMode = FlashMode.off;

  /// The current camera lens direction.
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  /// The underlying camera controller from the camera package.
  ///
  /// This provides direct access to the [CameraController] for advanced
  /// camera operations. Use with caution as direct manipulation may
  /// interfere with the guideline camera's state management.
  ///
  /// Returns `null` if the camera has not been initialized yet.
  ///
  /// See also:
  /// * [CameraController], for the underlying camera controller
  CameraController? get cameraController => _cameraController;

  /// The current state of the camera controller.
  ///
  /// This property indicates the current operational state of the camera:
  /// * [GuidelineState.initializing] - Camera is being set up
  /// * [GuidelineState.ready] - Camera is ready for capture
  /// * [GuidelineState.capturing] - Camera is currently taking a picture
  /// * [GuidelineState.error] - An error has occurred
  ///
  /// Example:
  /// ```dart
  /// if (controller.state == GuidelineState.ready) {
  ///   // Safe to capture images
  ///   await controller.capture();
  /// }
  /// ```
  ///
  /// See also:
  /// * [stateStream], for listening to state changes
  /// * [GuidelineState], for all available states
  GuidelineState get state => _state;

  /// A broadcast stream of guideline state changes.
  ///
  /// This stream emits a new [GuidelineState] whenever the controller's
  /// state changes. It's useful for reactive UI updates and state monitoring.
  ///
  /// Example:
  /// ```dart
  /// controller.stateStream.listen((state) {
  ///   switch (state) {
  ///     case GuidelineState.ready:
  ///       // Enable capture button
  ///       break;
  ///     case GuidelineState.error:
  ///       // Show error message
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// See also:
  /// * [state], for the current state
  /// * [GuidelineState], for available states
  Stream<GuidelineState> get stateStream => _stateStreamController.stream;

  /// The current flash mode setting.
  ///
  /// This property indicates how the camera flash is currently configured:
  /// * [FlashMode.off] - Flash is disabled
  /// * [FlashMode.always] - Flash is always on
  /// * [FlashMode.auto] - Flash is automatically controlled
  /// * [FlashMode.torch] - Flash is used as a torch (always on)
  ///
  /// Example:
  /// ```dart
  /// if (controller.flashMode == FlashMode.off) {
  ///   // Show flash off icon
  /// }
  /// ```
  ///
  /// See also:
  /// * [setFlashMode()], to change the flash mode
  /// * [FlashMode], for all available flash modes
  FlashMode get flashMode => _flashMode;

  /// The current camera lens direction.
  ///
  /// This property indicates which camera lens is currently active:
  /// * [CameraLensDirection.back] - Back/rear camera (default)
  /// * [CameraLensDirection.front] - Front/selfie camera
  ///
  /// Example:
  /// ```dart
  /// if (controller.lensDirection == CameraLensDirection.front) {
  ///   // Show selfie mode indicator
  /// }
  /// ```
  ///
  /// See also:
  /// * [switchCamera()], to change the camera lens
  /// * [CameraLensDirection], for all available directions
  CameraLensDirection get lensDirection => _lensDirection;

  /// Initializes the camera controller and sets up the camera for use.
  ///
  /// This method:
  /// 1. Discovers available cameras on the device
  /// 2. Selects the appropriate camera (prefers back camera)
  /// 3. Initializes the camera controller with medium resolution
  /// 4. Updates the controller state to [GuidelineState.ready]
  ///
  /// The method handles errors gracefully by setting the state to
  /// [GuidelineState.error] without throwing exceptions, allowing
  /// the UI to handle error states appropriately.
  ///
  /// Example:
  /// ```dart
  /// final controller = GuidelineCamController();
  /// try {
  ///   await controller.initialize();
  ///   print('Camera ready: ${controller.state}');
  /// } catch (e) {
  ///   print('Initialization failed: $e');
  /// }
  /// ```
  ///
  /// Throws [CameraException] if no cameras are available on the device.
  ///
  /// See also:
  /// * [state], to check the current state
  /// * [stateStream], to listen for state changes
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
            'NoCamerasAvailable', 'No cameras found on this device');
      }

      final camera = cameras.firstWhere(
          (c) => c.lensDirection == _lensDirection,
          orElse: () => cameras.first);

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _state = GuidelineState.ready;
    } catch (e) {
      _state = GuidelineState.error;
      _stateStreamController.add(_state);
      notifyListeners();
      // Don't rethrow - let the UI handle the error state
    } finally {
      if (_state != GuidelineState.error) {
        _stateStreamController.add(_state);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _stateStreamController.close();
    super.dispose();
  }

  /// Captures an image using the current camera.
  ///
  /// This method:
  /// 1. Sets the state to [GuidelineState.capturing]
  /// 2. Takes a picture using the camera controller
  /// 3. Returns the captured image file
  /// 4. Resets the state to [GuidelineState.ready]
  ///
  /// The captured image is saved to the device's temporary directory
  /// and can be accessed via the returned [XFile].
  ///
  /// Example:
  /// ```dart
  /// final result = await controller.capture();
  /// if (result != null) {
  ///   print('Image saved to: ${result.path}');
  ///   // Process the image file
  ///   final bytes = await result.readAsBytes();
  /// }
  /// ```
  ///
  /// Returns an [XFile] containing the captured image, or `null` if:
  /// * The camera controller is not initialized
  /// * The camera is not ready for capture
  ///
  /// Throws [CameraException] if capture fails due to camera issues.
  ///
  /// See also:
  /// * [state], to check if camera is ready for capture
  /// * [GuidelineCaptureResult], for structured capture results
  Future<XFile?> capture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      _state = GuidelineState.capturing;
      _stateStreamController.add(_state);
      notifyListeners();

      final image = await _cameraController!.takePicture();

      _state = GuidelineState.ready;
      _stateStreamController.add(_state);
      notifyListeners();

      return image;
    } catch (e) {
      _state = GuidelineState.error;
      _stateStreamController.add(_state);
      notifyListeners();
      rethrow;
    }
  }

  /// Switches the camera between front and back lenses.
  ///
  /// This method:
  /// 1. Disposes the current camera controller
  /// 2. Toggles between [CameraLensDirection.back] and [CameraLensDirection.front]
  /// 3. Reinitializes the camera with the new lens direction
  /// 4. Updates the state accordingly
  ///
  /// The camera switching process involves disposing the current controller
  /// and creating a new one, which may cause a brief delay in the UI.
  ///
  /// Example:
  /// ```dart
  /// // Switch from back to front camera
  /// await controller.switchCamera();
  /// print('Current lens: ${controller.lensDirection}');
  /// ```
  ///
  /// The method automatically handles errors during the switching process
  /// and will set the state to [GuidelineState.error] if switching fails.
  ///
  /// See also:
  /// * [lensDirection], to check the current camera direction
  /// * [initialize()], which is called internally during switching
  Future<void> switchCamera() async {
    // Dispose current controller before switching
    try {
      await _cameraController?.dispose();
    } catch (_) {}
    _cameraController = null;

    _lensDirection = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    _state = GuidelineState.initializing;
    _stateStreamController.add(_state);
    notifyListeners();

    await initialize();
  }

  /// Sets the flash mode for the camera.
  ///
  /// This method configures the camera's flash behavior for subsequent captures.
  /// The flash mode affects how the camera handles lighting during image capture.
  ///
  /// Example:
  /// ```dart
  /// // Enable flash for all captures
  /// await controller.setFlashMode(FlashMode.always);
  ///
  /// // Disable flash
  /// await controller.setFlashMode(FlashMode.off);
  ///
  /// // Auto flash (camera decides)
  /// await controller.setFlashMode(FlashMode.auto);
  /// ```
  ///
  /// Parameters:
  /// * [mode] - The flash mode to set. See [FlashMode] for available options.
  ///
  /// The method only applies the flash mode if the camera controller is
  /// initialized and ready. If the camera is not ready, the method
  /// will silently ignore the request.
  ///
  /// See also:
  /// * [flashMode], to check the current flash mode
  /// * [FlashMode], for available flash mode options
  Future<void> setFlashMode(FlashMode mode) async {
    if (_cameraController != null) {
      await _cameraController!.setFlashMode(mode);
      _flashMode = mode;
      notifyListeners();
    }
  }
}
