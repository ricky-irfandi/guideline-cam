import 'package:flutter/material.dart';
import 'package:guideline_cam/src/enums.dart';
import 'package:guideline_cam/src/multi_shape_config.dart';

/// Configuration for the guideline overlay appearance and behavior.
///
/// This class defines all the visual and behavioral properties of the overlay
/// that guides users during image capture. It supports both single-shape and
/// multi-shape overlays with extensive customization options.
///
/// ## Single Shape Overlay
///
/// For simple document or face capture with a single guideline shape:
///
/// ```dart
/// GuidelineOverlayConfig(
///   shape: GuidelineShape.roundedRect,
///   aspectRatio: 1.586, // ID card ratio
///   frameColor: Colors.white,
///   maskColor: Colors.black54,
///   strokeWidth: 2.0,
///   borderRadius: 12.0,
///   cornerLength: 20.0,
///   showGrid: true,
/// )
/// ```
///
/// ## Multi-Shape Overlay
///
/// For complex documents with multiple capture areas:
///
/// ```dart
/// GuidelineOverlayConfig(
///   shapes: [
///     // Main document area
///     ShapeConfig(
///       shape: GuidelineShape.roundedRect,
///       bounds: Rect.fromLTWH(50, 100, 300, 200),
///       aspectRatio: 1.5,
///       frameColor: Colors.white,
///     ),
///     // Signature area
///     ShapeConfig.inset(
///       shape: GuidelineShape.rect,
///       insets: EdgeInsets.only(bottom: 20, right: 20),
///       size: Size(0.3, 0.2), // 30% width, 20% height
///       frameColor: Colors.yellow,
///     ),
///   ],
///   maskColor: Colors.black54,
/// )
/// ```
///
/// ## Common Aspect Ratios
///
/// * **ID Cards**: 1.586 (standard credit card ratio)
/// * **Passports**: 1.42 (ISO 7810 ID-3)
/// * **Driver's License**: 1.586 (same as ID cards)
/// * **Business Cards**: 1.75 (standard business card)
/// * **Passport Photos**: 1.33 (4:3 ratio)
///
/// See also:
/// * [ShapeConfig], for individual shape configuration
/// * [GuidelineShape], for available shapes
/// * [MultiShapeOverlayConfig], for multi-shape overlays
class GuidelineOverlayConfig {
  const GuidelineOverlayConfig({
    this.shape = GuidelineShape.roundedRect,
    this.aspectRatio = 1.586,
    this.strokeWidth = 2.0,
    this.borderRadius = 12.0,
    this.maskColor = Colors.black54,
    this.frameColor = Colors.white,
    this.cornerLength = 20.0,
    this.padding = const EdgeInsets.all(20.0),
    this.showGrid = false,
    this.debugPaint = false,
    this.shapes,
  })  : assert(aspectRatio == null || aspectRatio > 0,
            'Aspect ratio must be positive'),
        assert(strokeWidth >= 0, 'Stroke width cannot be negative'),
        assert(borderRadius >= 0, 'Border radius cannot be negative'),
        assert(cornerLength >= 0, 'Corner length cannot be negative');

  /// The geometric shape of the guideline overlay.
  ///
  /// This determines the basic form of the overlay that guides users during
  /// image capture. Each shape is suitable for different types of documents
  /// or capture scenarios.
  ///
  /// Example:
  /// ```dart
  /// shape: GuidelineShape.roundedRect, // For ID cards and documents
  /// shape: GuidelineShape.circle,      // For face capture
  /// shape: GuidelineShape.oval,        // For passport photos
  /// shape: GuidelineShape.rect,        // For rectangular documents
  /// ```
  ///
  /// See also:
  /// * [GuidelineShape], for all available shapes
  final GuidelineShape shape;

  /// The aspect ratio (width/height) of the guideline overlay.
  ///
  /// This property constrains the overlay to maintain specific proportions,
  /// which is essential for capturing documents with standard dimensions.
  /// When `null`, the overlay uses the full available space.
  ///
  /// The aspect ratio is applied to all shapes except circles, which are
  /// always perfectly round regardless of this setting.
  ///
  /// Example:
  /// ```dart
  /// aspectRatio: 1.586,  // ID card ratio
  /// aspectRatio: 1.42,   // Passport ratio
  /// aspectRatio: 1.33,   // 4:3 ratio for photos
  /// aspectRatio: null,   // Use full available space
  /// ```
  ///
  /// See also:
  /// * [GuidelineShape], for shapes that respect aspect ratio
  final double? aspectRatio;

  /// The stroke width of the guideline overlay frame in logical pixels.
  ///
  /// This controls the thickness of the lines that form the overlay boundary.
  /// A thicker stroke makes the overlay more visible, while a thinner stroke
  /// provides a more subtle guide.
  ///
  /// Example:
  /// ```dart
  /// strokeWidth: 1.0,  // Thin, subtle frame
  /// strokeWidth: 2.0,  // Standard thickness (default)
  /// strokeWidth: 3.0,  // Thick, prominent frame
  /// ```
  ///
  /// Must be non-negative. Defaults to 2.0.
  final double strokeWidth;

  /// The border radius for rounded rectangle shapes in logical pixels.
  ///
  /// This property only affects [GuidelineShape.roundedRect] shapes, controlling
  /// how rounded the corners appear. A value of 0 creates sharp corners,
  /// while larger values create more rounded corners.
  ///
  /// Example:
  /// ```dart
  /// borderRadius: 0.0,   // Sharp corners (like rect)
  /// borderRadius: 8.0,   // Slightly rounded
  /// borderRadius: 12.0,  // Standard rounded (default)
  /// borderRadius: 20.0,  // Very rounded corners
  /// ```
  ///
  /// Must be non-negative. Defaults to 12.0.
  final double borderRadius;

  /// The color of the semi-transparent mask outside the guideline overlay.
  ///
  /// This color is applied to the area outside the overlay shape, creating
  /// a visual focus on the capture area. Typically, this should be a dark
  /// color with transparency to maintain visibility of the camera preview.
  ///
  /// Example:
  /// ```dart
  /// maskColor: Colors.black54,     // Standard dark mask (default)
  /// maskColor: Colors.black26,     // Lighter mask
  /// maskColor: Colors.black87,     // Darker mask
  /// maskColor: Colors.blue.withOpacity(0.3), // Colored mask
  /// ```
  ///
  /// Defaults to `Colors.black54`.
  final Color maskColor;

  /// The color of the guideline overlay frame and corner indicators.
  ///
  /// This color is used for the main overlay boundary, corner indicators
  /// (for rectangular shapes), and grid lines (when enabled). Choose a
  /// color that contrasts well with your camera preview content.
  ///
  /// Example:
  /// ```dart
  /// frameColor: Colors.white,      // Standard white frame (default)
  /// frameColor: Colors.yellow,     // High visibility yellow
  /// frameColor: Colors.green,      // Green for success indication
  /// frameColor: Colors.red,        // Red for error indication
  /// ```
  ///
  /// Defaults to `Colors.white`.
  final Color frameColor;

  /// The length of corner indicator lines for rectangular shapes in logical pixels.
  ///
  /// Corner indicators are small "L-shaped" lines at each corner of rectangular
  /// and rounded rectangular overlays that help users align their documents.
  /// Set to 0 to disable corner indicators.
  ///
  /// Example:
  /// ```dart
  /// cornerLength: 0.0,   // No corner indicators
  /// cornerLength: 15.0,  // Short corner indicators
  /// cornerLength: 20.0,  // Standard length (default)
  /// cornerLength: 30.0,  // Long corner indicators
  /// ```
  ///
  /// Must be non-negative. Defaults to 20.0.
  final double cornerLength;

  /// The padding around the guideline overlay from the screen edges.
  ///
  /// This creates a margin between the overlay and the screen boundaries,
  /// ensuring the overlay doesn't touch the edges and provides a comfortable
  /// capture area. The padding is applied to all sides.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(20.0),           // Uniform padding (default)
  /// padding: EdgeInsets.all(40.0),           // Larger padding
  /// padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20), // Different horizontal/vertical
  /// padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 100), // Custom per side
  /// ```
  ///
  /// Defaults to `EdgeInsets.all(20.0)`.
  final EdgeInsets padding;

  /// Whether to display a 3x3 grid inside the guideline overlay.
  ///
  /// When enabled, a grid of lines is drawn inside the overlay to help users
  /// align their documents more precisely. The grid uses the same color as
  /// the frame but with reduced opacity for subtlety.
  ///
  /// Example:
  /// ```dart
  /// showGrid: true,   // Display alignment grid
  /// showGrid: false,  // No grid (default)
  /// ```
  ///
  /// The grid is particularly useful for document capture where precise
  /// alignment is important.
  final bool showGrid;

  /// Whether to display debug information during development.
  ///
  /// When enabled in debug mode, this draws additional visual information
  /// such as shape boundaries and positioning guides. This is useful for
  /// debugging overlay positioning and multi-shape configurations.
  ///
  /// Example:
  /// ```dart
  /// debugPaint: true,   // Show debug info in debug mode
  /// debugPaint: false,  // No debug info (default)
  /// ```
  ///
  /// Debug information is only shown when `kDebugMode` is true.
  final bool debugPaint;

  /// Optional list of shapes for creating multi-shape overlays.
  ///
  /// When provided, this overrides the single shape configuration and creates
  /// a complex overlay with multiple capture areas. Each [ShapeConfig] in the
  /// list defines a separate shape with its own properties and positioning.
  ///
  /// Example:
  /// ```dart
  /// shapes: [
  ///   // Main document area
  ///   ShapeConfig(
  ///     shape: GuidelineShape.roundedRect,
  ///     bounds: Rect.fromLTWH(50, 100, 300, 200),
  ///     frameColor: Colors.white,
  ///   ),
  ///   // Signature area
  ///   ShapeConfig.inset(
  ///     shape: GuidelineShape.rect,
  ///     insets: EdgeInsets.only(bottom: 20, right: 20),
  ///     frameColor: Colors.yellow,
  ///   ),
  /// ],
  /// ```
  ///
  /// When `shapes` is provided, the single shape properties ([shape],
  /// [aspectRatio], etc.) are ignored.
  ///
  /// See also:
  /// * [ShapeConfig], for individual shape configuration
  /// * [isMultiShape], to check if this is a multi-shape configuration
  final List<ShapeConfig>? shapes;

  /// Whether this configuration uses multiple shapes.
  ///
  /// Returns `true` if the [shapes] list is provided and contains at least
  /// one shape configuration. When `true`, the single shape properties
  /// ([shape], [aspectRatio], etc.) are ignored in favor of the multi-shape
  /// configuration.
  ///
  /// Example:
  /// ```dart
  /// final config = GuidelineOverlayConfig(
  ///   shapes: [ShapeConfig(...)],
  /// );
  /// print(config.isMultiShape); // true
  /// ```
  ///
  /// See also:
  /// * [shapes], for the multi-shape configuration
  /// * [toMultiShapeConfig()], to convert to multi-shape config
  bool get isMultiShape => shapes != null && shapes!.isNotEmpty;

  /// Creates a [MultiShapeOverlayConfig] from this configuration.
  ///
  /// This method converts the current configuration to a multi-shape overlay
  /// configuration, preserving the mask color and debug settings while using
  /// the shapes list for rendering.
  ///
  /// Returns `null` if this is not a multi-shape configuration (i.e., if
  /// [isMultiShape] returns `false`).
  ///
  /// Example:
  /// ```dart
  /// final config = GuidelineOverlayConfig(
  ///   shapes: [
  ///     ShapeConfig(shape: GuidelineShape.rect, bounds: Rect.fromLTWH(0, 0, 100, 100)),
  ///   ],
  ///   maskColor: Colors.black54,
  ///   debugPaint: true,
  /// );
  ///
  /// final multiConfig = config.toMultiShapeConfig();
  /// if (multiConfig != null) {
  ///   // Use multi-shape painter
  ///   CustomPaint(painter: MultiShapeOverlayPainter(multiConfig));
  /// }
  /// ```
  ///
  /// Returns a [MultiShapeOverlayConfig] if this is a multi-shape configuration,
  /// or `null` if it's a single-shape configuration.
  ///
  /// See also:
  /// * [isMultiShape], to check if conversion is possible
  /// * [MultiShapeOverlayConfig], for the returned configuration type
  MultiShapeOverlayConfig? toMultiShapeConfig() {
    if (!isMultiShape) return null;

    return MultiShapeOverlayConfig(
      shapes: shapes!,
      maskColor: maskColor,
      debugPaint: debugPaint,
    );
  }
}
