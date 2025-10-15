/// The geometric shape of the guideline overlay.
///
/// This enum defines the available shapes for camera overlays, each optimized
/// for different types of document or image capture scenarios.
///
/// ## Usage Examples
///
/// ```dart
/// // For rectangular documents (forms, letters, etc.)
/// GuidelineOverlayConfig(shape: GuidelineShape.rect)
///
/// // For ID cards, credit cards, and similar documents
/// GuidelineOverlayConfig(shape: GuidelineShape.roundedRect)
///
/// // For face capture, biometric photos, profile pictures
/// GuidelineOverlayConfig(shape: GuidelineShape.circle)
///
/// // For passport photos, visa photos, official portraits
/// GuidelineOverlayConfig(shape: GuidelineShape.oval)
/// ```
///
/// See also:
/// * [GuidelineOverlayConfig], for using these shapes
/// * [ShapeConfig], for multi-shape overlays
enum GuidelineShape {
  /// A plain rectangle with sharp corners.
  ///
  /// Best suited for:
  /// * Business documents
  /// * Letters and forms
  /// * Rectangular certificates
  /// * Any document with sharp, defined edges
  ///
  /// Example:
  /// ```dart
  /// GuidelineOverlayConfig(
  ///   shape: GuidelineShape.rect,
  ///   aspectRatio: 1.414, // A4 paper ratio
  /// )
  /// ```
  rect,

  /// A rectangle with rounded corners.
  ///
  /// Best suited for:
  /// * ID cards and driver's licenses
  /// * Credit cards and payment cards
  /// * Business cards
  /// * Modern documents with rounded corners
  ///
  /// This is the most commonly used shape for document capture as it matches
  /// the appearance of most modern identification and payment cards.
  ///
  /// Example:
  /// ```dart
  /// GuidelineOverlayConfig(
  ///   shape: GuidelineShape.roundedRect,
  ///   aspectRatio: 1.586, // Standard credit card ratio
  ///   borderRadius: 12.0,  // Corner roundness
  /// )
  /// ```
  roundedRect,

  /// A perfect circle, ideal for face or biometric capture.
  ///
  /// Best suited for:
  /// * Face recognition photos
  /// * Profile pictures
  /// * Biometric capture
  /// * Circular logos or stamps
  /// * Any content that should be captured in a circular frame
  ///
  /// Note: Circles ignore aspect ratio settings and are always perfectly round.
  ///
  /// Example:
  /// ```dart
  /// GuidelineOverlayConfig(
  ///   shape: GuidelineShape.circle,
  ///   frameColor: Colors.blue,
  ///   showGrid: true, // Help with face alignment
  /// )
  /// ```
  circle,

  /// An oval/ellipse, perfect for passport photos and official portraits.
  ///
  /// Best suited for:
  /// * Passport photos
  /// * Visa application photos
  /// * Official portrait requirements
  /// * Any content requiring an oval frame
  ///
  /// Ovals respect aspect ratio settings and can be stretched to match
  /// specific portrait requirements.
  ///
  /// Example:
  /// ```dart
  /// GuidelineOverlayConfig(
  ///   shape: GuidelineShape.oval,
  ///   aspectRatio: 1.33, // 4:3 ratio for passport photos
  /// )
  /// ```
  oval,
}

/// The current operational state of the camera controller.
///
/// This enum represents the different states that the camera can be in during
/// its lifecycle. The state changes are automatically managed by the
/// [GuidelineCamController] and can be monitored through the [state] property
/// or [stateStream].
///
/// ## State Flow
///
/// ```
/// initializing → ready → capturing → ready
///      ↓
///    error
/// ```
///
/// ## Usage Examples
///
/// ```dart
/// // Check current state
/// if (controller.state == GuidelineState.ready) {
///   // Safe to capture images
///   await controller.capture();
/// }
///
/// // Listen to state changes
/// controller.stateStream.listen((state) {
///   switch (state) {
///     case GuidelineState.initializing:
///       showLoadingIndicator();
///       break;
///     case GuidelineState.ready:
///       hideLoadingIndicator();
///       enableCaptureButton();
///       break;
///     case GuidelineState.capturing:
///       showCaptureProgress();
///       break;
///     case GuidelineState.error:
///       showErrorMessage();
///       break;
///   }
/// });
/// ```
///
/// See also:
/// * [GuidelineCamController.state], for the current state
/// * [GuidelineCamController.stateStream], for state change notifications
enum GuidelineState {
  /// The camera is being initialized and set up.
  ///
  /// This state occurs when:
  /// * The controller is first created
  /// * [GuidelineCamController.initialize()] is called
  /// * The camera is being switched between front and back
  ///
  /// During this state:
  /// * Camera hardware is being accessed
  /// * Camera controller is being configured
  /// * UI should show a loading indicator
  /// * Capture operations are not available
  ///
  /// Example:
  /// ```dart
  /// if (controller.state == GuidelineState.initializing) {
  ///   return CircularProgressIndicator();
  /// }
  /// ```
  initializing,

  /// The camera is ready for capture operations.
  ///
  /// This is the normal operational state where:
  /// * Camera preview is active
  /// * Image capture is available
  /// * Flash and camera switching work
  /// * UI should show the camera interface
  ///
  /// Example:
  /// ```dart
  /// if (controller.state == GuidelineState.ready) {
  ///   return FloatingActionButton(
  ///     onPressed: () => controller.capture(),
  ///     child: Icon(Icons.camera_alt),
  ///   );
  /// }
  /// ```
  ready,

  /// The camera is currently capturing an image.
  ///
  /// This brief state occurs during:
  /// * Image capture process
  /// * File writing to storage
  /// * Processing the captured image
  ///
  /// During this state:
  /// * UI should show capture progress
  /// * Additional capture requests should be disabled
  /// * The state automatically returns to [ready] when complete
  ///
  /// Example:
  /// ```dart
  /// if (controller.state == GuidelineState.capturing) {
  ///   return CircularProgressIndicator(
  ///     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  ///   );
  /// }
  /// ```
  capturing,

  /// An error has occurred with the camera.
  ///
  /// This state indicates a problem such as:
  /// * Camera permission denied
  /// * No cameras available on device
  /// * Hardware failure
  /// * Initialization failure
  ///
  /// When in error state:
  /// * Camera operations are not available
  /// * UI should show error message
  /// * User should be prompted to retry or check permissions
  ///
  /// Example:
  /// ```dart
  /// if (controller.state == GuidelineState.error) {
  ///   return Column(
  ///     children: [
  ///       Icon(Icons.error, color: Colors.red),
  ///       Text('Camera error occurred'),
  ///       ElevatedButton(
  ///         onPressed: () => controller.initialize(),
  ///         child: Text('Retry'),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  error,
}

/// The positioning mode for child shapes within parent shapes in multi-shape overlays.
///
/// This enum defines how child shapes are positioned relative to their parent
/// shapes in complex multi-shape configurations. Each mode provides different
/// levels of control and flexibility for creating sophisticated overlay layouts.
///
/// ## Usage Examples
///
/// ```dart
/// // Absolute positioning with fixed coordinates
/// ShapeConfig(
///   shape: GuidelineShape.rect,
///   bounds: Rect.fromLTWH(100, 200, 150, 100), // Fixed position
///   positioning: ShapePositioning.absolute,
/// )
///
/// // Relative positioning with percentage-based coordinates
/// ShapeConfig.relativePosition(
///   shape: GuidelineShape.circle,
///   relativeOffset: Offset(0.5, 0.3), // 50% from left, 30% from top
///   size: Size(0.2, 0.2), // 20% of parent size
/// )
///
/// // Centered positioning
/// ShapeConfig.centered(
///   shape: GuidelineShape.roundedRect,
///   size: Size(200, 100), // Fixed size, centered
/// )
///
/// // Inset positioning with margins from edges
/// ShapeConfig.inset(
///   shape: GuidelineShape.rect,
///   insets: EdgeInsets.only(bottom: 20, right: 20), // 20px from bottom-right
///   size: Size(0.3, 0.2), // 30% width, 20% height
/// )
/// ```
///
/// See also:
/// * [ShapeConfig], for using these positioning modes
/// * [MultiShapeOverlayConfig], for multi-shape overlays
enum ShapePositioning {
  /// Uses fixed pixel coordinates for absolute positioning.
  ///
  /// This mode positions the shape using exact pixel coordinates relative
  /// to the screen or parent container. The shape's position is fixed and
  /// doesn't change based on parent size or screen dimensions.
  ///
  /// Best for:
  /// * Precise positioning requirements
  /// * Fixed-size overlays
  /// * When you need exact control over placement
  ///
  /// Example:
  /// ```dart
  /// ShapeConfig(
  ///   shape: GuidelineShape.rect,
  ///   bounds: Rect.fromLTWH(50, 100, 200, 150), // Fixed position and size
  ///   positioning: ShapePositioning.absolute,
  /// )
  /// ```
  ///
  /// The [bounds] property defines the exact position and size in pixels.
  absolute,

  /// Position relative to parent's bounds using percentage-based coordinates.
  ///
  /// This mode positions the shape using relative coordinates (0.0 to 1.0)
  /// that represent percentages of the parent's dimensions. The shape's
  /// position scales with the parent size, making it responsive to different
  /// screen sizes.
  ///
  /// Best for:
  /// * Responsive layouts
  /// * Shapes that should scale with parent
  /// * Percentage-based positioning
  ///
  /// Example:
  /// ```dart
  /// ShapeConfig.relativePosition(
  ///   shape: GuidelineShape.circle,
  ///   relativeOffset: Offset(0.5, 0.3), // 50% from left, 30% from top
  ///   size: Size(0.2, 0.2), // 20% of parent width and height
  /// )
  /// ```
  ///
  /// The [relativeOffset] property uses values from 0.0 to 1.0.
  relative,

  /// Automatically centered within the parent shape.
  ///
  /// This mode automatically centers the shape within its parent, regardless
  /// of the parent's size or position. The shape maintains its specified size
  /// but is positioned at the center of the parent bounds.
  ///
  /// Best for:
  /// * Centered elements (logos, stamps, signatures)
  /// * When you want automatic centering
  /// * Simplified positioning logic
  ///
  /// Example:
  /// ```dart
  /// ShapeConfig.centered(
  ///   shape: GuidelineShape.circle,
  ///   size: Size(100, 100), // Fixed size, automatically centered
  /// )
  /// ```
  ///
  /// The shape is centered both horizontally and vertically within the parent.
  center,

  /// Position with specific pixel offsets from parent edges.
  ///
  /// This mode positions the shape using insets (margins) from the parent's
  /// edges. You specify how far the shape should be from each edge of the
  /// parent, allowing for flexible positioning while maintaining relationships
  /// to the parent boundaries.
  ///
  /// Best for:
  /// * Corner positioning (signatures, stamps)
  /// * Margin-based layouts
  /// * When you need distance from edges
  ///
  /// Example:
  /// ```dart
  /// ShapeConfig.inset(
  ///   shape: GuidelineShape.rect,
  ///   insets: EdgeInsets.only(bottom: 20, right: 20), // 20px from bottom-right
  ///   size: Size(0.3, 0.2), // 30% width, 20% height of parent
  /// )
  /// ```
  ///
  /// The [insets] property defines margins from each edge of the parent.
  inset,
}
