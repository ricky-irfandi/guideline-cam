import 'package:flutter/material.dart';
import 'package:guideline_cam/src/enums.dart';

/// Configuration for a single shape within a multi-shape overlay.
///
/// This class defines the properties and positioning of individual shapes
/// in complex multi-shape overlays. Each shape can have its own appearance,
/// size, position, and even nested child shapes for sophisticated layouts.
///
/// ## Basic Shape Configuration
///
/// ```dart
/// // Simple rectangular shape
/// ShapeConfig(
///   shape: GuidelineShape.rect,
///   bounds: Rect.fromLTWH(50, 100, 200, 150),
///   frameColor: Colors.white,
///   strokeWidth: 2.0,
/// )
///
/// // Rounded rectangle with aspect ratio
/// ShapeConfig(
///   shape: GuidelineShape.roundedRect,
///   bounds: Rect.fromLTWH(100, 200, 300, 200),
///   aspectRatio: 1.5,
///   borderRadius: 12.0,
///   frameColor: Colors.blue,
/// )
/// ```
///
/// ## Advanced Positioning
///
/// ```dart
/// // Centered child shape
/// ShapeConfig.centered(
///   shape: GuidelineShape.circle,
///   size: Size(100, 100),
///   frameColor: Colors.yellow,
/// )
///
/// // Shape positioned with insets
/// ShapeConfig.inset(
///   shape: GuidelineShape.rect,
///   insets: EdgeInsets.only(bottom: 20, right: 20),
///   size: Size(0.3, 0.2), // 30% width, 20% height
///   frameColor: Colors.green,
/// )
///
/// // Relative positioning
/// ShapeConfig.relativePosition(
///   shape: GuidelineShape.oval,
///   relativeOffset: Offset(0.5, 0.3), // 50% from left, 30% from top
///   size: Size(0.4, 0.3), // 40% width, 30% height
///   frameColor: Colors.red,
/// )
/// ```
///
/// ## Nested Shapes
///
/// ```dart
/// // Parent shape with child shapes
/// ShapeConfig(
///   shape: GuidelineShape.roundedRect,
///   bounds: Rect.fromLTWH(50, 100, 300, 200),
///   frameColor: Colors.white,
///   children: [
///     // Signature area in bottom-right corner
///     ShapeConfig.inset(
///       shape: GuidelineShape.rect,
///       insets: EdgeInsets.only(bottom: 20, right: 20),
///       size: Size(0.3, 0.2),
///       frameColor: Colors.yellow,
///     ),
///     // Date stamp in top-left corner
///     ShapeConfig.inset(
///       shape: GuidelineShape.circle,
///       insets: EdgeInsets.only(top: 20, left: 20),
///       size: Size(0.15, 0.15),
///       frameColor: Colors.blue,
///     ),
///   ],
/// )
/// ```
///
/// See also:
/// * [MultiShapeOverlayConfig], for multi-shape overlay configuration
/// * [ShapePositioning], for positioning modes
/// * [GuidelineShape], for available shapes
class ShapeConfig {
  const ShapeConfig({
    required this.shape,
    required this.bounds,
    this.aspectRatio,
    this.strokeWidth = 2.0,
    this.borderRadius = 12.0,
    this.frameColor = Colors.white,
    this.cornerLength = 20.0,
    this.showGrid = false,
    this.children,
    this.positioning = ShapePositioning.absolute,
    this.relativeOffset,
    this.insets,
    this.size,
  })  : assert(strokeWidth >= 0, 'Stroke width cannot be negative'),
        assert(borderRadius >= 0, 'Border radius cannot be negative'),
        assert(cornerLength >= 0, 'Corner length cannot be negative');

  /// Creates a ShapeConfig with additional validation for relative positioning.
  ///
  /// This factory constructor provides extra validation for relative positioning
  /// parameters, ensuring that relative offsets are within valid ranges (0.0 to 1.0)
  /// and that size dimensions are non-negative.
  ///
  /// Use this constructor when you need to ensure data integrity for complex
  /// positioning scenarios, especially when working with user-provided values
  /// or dynamic positioning calculations.
  ///
  /// Example:
  /// ```dart
  /// // Safe creation with validation
  /// final shape = ShapeConfig.withValidation(
  ///   shape: GuidelineShape.rect,
  ///   bounds: Rect.fromLTWH(0, 0, 100, 100),
  ///   relativeOffset: Offset(0.5, 0.3), // Valid: within 0.0-1.0 range
  ///   size: Size(0.2, 0.2), // Valid: non-negative
  ///   positioning: ShapePositioning.relative,
  /// );
  ///
  /// // This would throw an assertion error:
  /// // ShapeConfig.withValidation(
  /// //   relativeOffset: Offset(1.5, 0.3), // Invalid: > 1.0
  /// //   ...
  /// // );
  /// ```
  ///
  /// Parameters:
  /// * [shape] - The shape type
  /// * [bounds] - The shape bounds
  /// * [aspectRatio] - Optional aspect ratio constraint
  /// * [strokeWidth] - Stroke width (must be non-negative)
  /// * [borderRadius] - Border radius (must be non-negative)
  /// * [frameColor] - Frame color
  /// * [cornerLength] - Corner length (must be non-negative)
  /// * [showGrid] - Whether to show grid
  /// * [children] - Optional child shapes
  /// * [positioning] - Positioning mode
  /// * [relativeOffset] - Relative offset (must be 0.0-1.0 if provided)
  /// * [insets] - Edge insets for inset positioning
  /// * [size] - Shape size (must be non-negative if provided)
  ///
  /// Throws [AssertionError] if validation fails.
  ///
  /// See also:
  /// * [ShapeConfig], for the standard constructor
  /// * [ShapePositioning], for positioning modes
  factory ShapeConfig.withValidation({
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
  }) {
    assert(strokeWidth >= 0, 'Stroke width cannot be negative');
    assert(borderRadius >= 0, 'Border radius cannot be negative');
    assert(cornerLength >= 0, 'Corner length cannot be negative');
    assert(
        relativeOffset == null ||
            (relativeOffset.dx >= 0.0 &&
                relativeOffset.dx <= 1.0 &&
                relativeOffset.dy >= 0.0 &&
                relativeOffset.dy <= 1.0),
        'Relative offset values must be between 0.0 and 1.0');
    assert(size == null || (size.width >= 0 && size.height >= 0),
        'Size dimensions must be non-negative');

    return ShapeConfig(
      shape: shape,
      bounds: bounds,
      aspectRatio: aspectRatio,
      strokeWidth: strokeWidth,
      borderRadius: borderRadius,
      frameColor: frameColor,
      cornerLength: cornerLength,
      showGrid: showGrid,
      children: children,
      positioning: positioning,
      relativeOffset: relativeOffset,
      insets: insets,
      size: size,
    );
  }

  /// The shape type.
  final GuidelineShape shape;

  /// The bounds of the shape within the overlay.
  final Rect bounds;

  /// The aspect ratio of the shape (only applies to rect, roundedRect, oval).
  final double? aspectRatio;

  /// The stroke width of the shape frame.
  final double strokeWidth;

  /// The border radius for rounded rectangles.
  final double borderRadius;

  /// The color of the shape frame.
  final Color frameColor;

  /// The length of corner indicators for rectangles.
  final double cornerLength;

  /// Whether to show a 3x3 grid inside the shape.
  final bool showGrid;

  /// Optional list of child shapes within this shape.
  final List<ShapeConfig>? children;

  /// The positioning mode for this shape relative to its parent.
  final ShapePositioning positioning;

  /// The relative offset for positioning (0.0 to 1.0 range).
  /// Only used when positioning is ShapePositioning.relative.
  final Offset? relativeOffset;

  /// The insets for positioning from parent edges.
  /// Only used when positioning is ShapePositioning.inset.
  final EdgeInsets? insets;

  /// The explicit size for the shape.
  /// Can be absolute pixels or relative to parent (0.0 to 1.0 range).
  final Size? size;

  /// Creates a copy of this ShapeConfig with the given fields replaced.
  ShapeConfig copyWith({
    GuidelineShape? shape,
    Rect? bounds,
    double? aspectRatio,
    double? strokeWidth,
    double? borderRadius,
    Color? frameColor,
    double? cornerLength,
    bool? showGrid,
    List<ShapeConfig>? children,
    ShapePositioning? positioning,
    Offset? relativeOffset,
    EdgeInsets? insets,
    Size? size,
  }) {
    return ShapeConfig(
      shape: shape ?? this.shape,
      bounds: bounds ?? this.bounds,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      frameColor: frameColor ?? this.frameColor,
      cornerLength: cornerLength ?? this.cornerLength,
      showGrid: showGrid ?? this.showGrid,
      children: children ?? this.children,
      positioning: positioning ?? this.positioning,
      relativeOffset: relativeOffset ?? this.relativeOffset,
      insets: insets ?? this.insets,
      size: size ?? this.size,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShapeConfig &&
        other.shape == shape &&
        other.bounds == bounds &&
        other.aspectRatio == aspectRatio &&
        other.strokeWidth == strokeWidth &&
        other.borderRadius == borderRadius &&
        other.frameColor == frameColor &&
        other.cornerLength == cornerLength &&
        other.showGrid == showGrid &&
        other.children == children &&
        other.positioning == positioning &&
        other.relativeOffset == relativeOffset &&
        other.insets == insets &&
        other.size == size;
  }

  @override
  int get hashCode {
    return Object.hash(
      shape,
      bounds,
      aspectRatio,
      strokeWidth,
      borderRadius,
      frameColor,
      cornerLength,
      showGrid,
      children,
      positioning,
      relativeOffset,
      insets,
      size,
    );
  }

  /// Creates a child shape that is automatically centered within its parent.
  ///
  /// This factory constructor creates a shape that will be positioned at the
  /// center of its parent shape, regardless of the parent's size or position.
  /// The shape maintains its specified size but is automatically centered
  /// both horizontally and vertically.
  ///
  /// This is useful for creating centered elements like logos, stamps, or
  /// signature areas that should always appear in the middle of a document
  /// capture area.
  ///
  /// Example:
  /// ```dart
  /// // Centered circular logo
  /// ShapeConfig.centered(
  ///   shape: GuidelineShape.circle,
  ///   size: Size(80, 80),
  ///   frameColor: Colors.blue,
  ///   strokeWidth: 3.0,
  /// )
  ///
  /// // Centered rectangular stamp area
  /// ShapeConfig.centered(
  ///   shape: GuidelineShape.roundedRect,
  ///   size: Size(120, 60),
  ///   borderRadius: 8.0,
  ///   frameColor: Colors.red,
  ///   showGrid: true,
  /// )
  /// ```
  ///
  /// Parameters:
  /// * [shape] - The shape type to create
  /// * [size] - The size of the shape (can be absolute or relative)
  /// * [aspectRatio] - Optional aspect ratio constraint
  /// * [strokeWidth] - Stroke width for the frame
  /// * [borderRadius] - Border radius for rounded rectangles
  /// * [frameColor] - Color of the frame
  /// * [cornerLength] - Length of corner indicators
  /// * [showGrid] - Whether to show alignment grid
  /// * [children] - Optional nested child shapes
  ///
  /// The shape will be automatically positioned at the center of its parent
  /// when rendered in a multi-shape overlay.
  ///
  /// See also:
  /// * [ShapeConfig.inset], for edge-positioned shapes
  /// * [ShapeConfig.relativePosition], for percentage-based positioning
  factory ShapeConfig.centered({
    required GuidelineShape shape,
    required Size size,
    double? aspectRatio,
    double strokeWidth = 2.0,
    double borderRadius = 12.0,
    Color frameColor = Colors.white,
    double cornerLength = 20.0,
    bool showGrid = false,
    List<ShapeConfig>? children,
  }) {
    return ShapeConfig(
      shape: shape,
      bounds: Rect.zero, // Will be calculated based on parent
      aspectRatio: aspectRatio,
      strokeWidth: strokeWidth,
      borderRadius: borderRadius,
      frameColor: frameColor,
      cornerLength: cornerLength,
      showGrid: showGrid,
      children: children,
      positioning: ShapePositioning.center,
      size: size,
    );
  }

  /// Creates a child shape positioned with insets from parent edges.
  ///
  /// This factory constructor creates a shape that is positioned using margins
  /// (insets) from the edges of its parent shape. You specify how far the shape
  /// should be from each edge, allowing for flexible positioning while maintaining
  /// relationships to the parent boundaries.
  ///
  /// This is particularly useful for corner positioning, such as signature areas,
  /// date stamps, or other elements that should appear at specific distances
  /// from document edges.
  ///
  /// Example:
  /// ```dart
  /// // Signature area in bottom-right corner
  /// ShapeConfig.inset(
  ///   shape: GuidelineShape.rect,
  ///   insets: EdgeInsets.only(bottom: 20, right: 20),
  ///   size: Size(0.3, 0.2), // 30% width, 20% height of parent
  ///   frameColor: Colors.yellow,
  /// )
  ///
  /// // Date stamp in top-left corner
  /// ShapeConfig.inset(
  ///   shape: GuidelineShape.circle,
  ///   insets: EdgeInsets.only(top: 15, left: 15),
  ///   size: Size(0.1, 0.1), // 10% of parent size
  ///   frameColor: Colors.blue,
  /// )
  ///
  /// // Full margin from all edges
  /// ShapeConfig.inset(
  ///   shape: GuidelineShape.roundedRect,
  ///   insets: EdgeInsets.all(30),
  ///   size: Size(0.8, 0.6), // 80% width, 60% height
  ///   frameColor: Colors.green,
  /// )
  /// ```
  ///
  /// Parameters:
  /// * [shape] - The shape type to create
  /// * [insets] - Margins from parent edges
  /// * [size] - The size of the shape (can be absolute or relative)
  /// * [aspectRatio] - Optional aspect ratio constraint
  /// * [strokeWidth] - Stroke width for the frame
  /// * [borderRadius] - Border radius for rounded rectangles
  /// * [frameColor] - Color of the frame
  /// * [cornerLength] - Length of corner indicators
  /// * [showGrid] - Whether to show alignment grid
  /// * [children] - Optional nested child shapes
  ///
  /// The shape will be positioned at the specified distance from the parent's
  /// edges when rendered in a multi-shape overlay.
  ///
  /// See also:
  /// * [ShapeConfig.centered], for centered positioning
  /// * [ShapeConfig.relativePosition], for percentage-based positioning
  factory ShapeConfig.inset({
    required GuidelineShape shape,
    required EdgeInsets insets,
    Size? size,
    double? aspectRatio,
    double strokeWidth = 2.0,
    double borderRadius = 12.0,
    Color frameColor = Colors.white,
    double cornerLength = 20.0,
    bool showGrid = false,
    List<ShapeConfig>? children,
  }) {
    return ShapeConfig(
      shape: shape,
      bounds: Rect.zero, // Will be calculated based on parent
      aspectRatio: aspectRatio,
      strokeWidth: strokeWidth,
      borderRadius: borderRadius,
      frameColor: frameColor,
      cornerLength: cornerLength,
      showGrid: showGrid,
      children: children,
      positioning: ShapePositioning.inset,
      insets: insets,
      size: size,
    );
  }

  /// Creates a child shape positioned relative to its parent using percentage coordinates.
  ///
  /// This factory constructor creates a shape that is positioned using relative
  /// coordinates (0.0 to 1.0) that represent percentages of the parent's dimensions.
  /// The shape's position scales with the parent size, making it responsive to
  /// different screen sizes and parent dimensions.
  ///
  /// This is ideal for creating responsive layouts where shapes should maintain
  /// their relative positions regardless of the parent's actual size.
  ///
  /// Example:
  /// ```dart
  /// // Shape at 50% from left, 30% from top
  /// ShapeConfig.relativePosition(
  ///   shape: GuidelineShape.circle,
  ///   relativeOffset: Offset(0.5, 0.3), // Center horizontally, 30% from top
  ///   size: Size(0.2, 0.2), // 20% of parent width and height
  ///   frameColor: Colors.red,
  /// )
  ///
  /// // Shape in top-right area
  /// ShapeConfig.relativePosition(
  ///   shape: GuidelineShape.rect,
  ///   relativeOffset: Offset(0.8, 0.2), // 80% from left, 20% from top
  ///   size: Size(0.15, 0.1), // 15% width, 10% height
  ///   frameColor: Colors.blue,
  /// )
  ///
  /// // Shape in bottom-left area
  /// ShapeConfig.relativePosition(
  ///   shape: GuidelineShape.oval,
  ///   relativeOffset: Offset(0.2, 0.8), // 20% from left, 80% from top
  ///   size: Size(0.25, 0.15), // 25% width, 15% height
  ///   frameColor: Colors.green,
  /// )
  /// ```
  ///
  /// Parameters:
  /// * [shape] - The shape type to create
  /// * [relativeOffset] - Position as percentage of parent (0.0-1.0 range)
  /// * [size] - The size of the shape (can be absolute or relative)
  /// * [aspectRatio] - Optional aspect ratio constraint
  /// * [strokeWidth] - Stroke width for the frame
  /// * [borderRadius] - Border radius for rounded rectangles
  /// * [frameColor] - Color of the frame
  /// * [cornerLength] - Length of corner indicators
  /// * [showGrid] - Whether to show alignment grid
  /// * [children] - Optional nested child shapes
  ///
  /// The [relativeOffset] values must be between 0.0 and 1.0, where:
  /// * 0.0 represents the left/top edge of the parent
  /// * 1.0 represents the right/bottom edge of the parent
  /// * 0.5 represents the center of the parent
  ///
  /// See also:
  /// * [ShapeConfig.centered], for centered positioning
  /// * [ShapeConfig.inset], for edge-based positioning
  factory ShapeConfig.relativePosition({
    required GuidelineShape shape,
    required Offset relativeOffset,
    Size? size,
    double? aspectRatio,
    double strokeWidth = 2.0,
    double borderRadius = 12.0,
    Color frameColor = Colors.white,
    double cornerLength = 20.0,
    bool showGrid = false,
    List<ShapeConfig>? children,
  }) {
    return ShapeConfig(
      shape: shape,
      bounds: Rect.zero, // Will be calculated based on parent
      aspectRatio: aspectRatio,
      strokeWidth: strokeWidth,
      borderRadius: borderRadius,
      frameColor: frameColor,
      cornerLength: cornerLength,
      showGrid: showGrid,
      children: children,
      positioning: ShapePositioning.relative,
      relativeOffset: relativeOffset,
      size: size,
    );
  }
}

/// Configuration for multi-shape overlays with unified masking.
///
/// This class defines the configuration for complex overlays that contain multiple
/// shapes with different properties and positioning. It provides unified masking
/// across all shapes while allowing individual shape customization.
///
/// ## Basic Multi-Shape Configuration
///
/// ```dart
/// MultiShapeOverlayConfig(
///   shapes: [
///     // Main document area
///     ShapeConfig(
///       shape: GuidelineShape.roundedRect,
///       bounds: Rect.fromLTWH(50, 100, 300, 200),
///       frameColor: Colors.white,
///       strokeWidth: 2.0,
///     ),
///     // Signature area
///     ShapeConfig.inset(
///       shape: GuidelineShape.rect,
///       insets: EdgeInsets.only(bottom: 20, right: 20),
///       size: Size(0.3, 0.2),
///       frameColor: Colors.yellow,
///     ),
///   ],
///   maskColor: Colors.black54,
///   debugPaint: false,
/// )
/// ```
///
/// ## Complex Document Layout
///
/// ```dart
/// MultiShapeOverlayConfig(
///   shapes: [
///     // Main document frame
///     ShapeConfig(
///       shape: GuidelineShape.roundedRect,
///       bounds: Rect.fromLTWH(40, 80, 320, 400),
///       aspectRatio: 0.8, // Portrait orientation
///       frameColor: Colors.white,
///       strokeWidth: 3.0,
///       showGrid: true,
///       children: [
///         // Header area
///         ShapeConfig.inset(
///           shape: GuidelineShape.rect,
///           insets: EdgeInsets.only(top: 20, left: 20, right: 20),
///           size: Size(1.0, 0.15), // Full width, 15% height
///           frameColor: Colors.blue,
///         ),
///         // Signature area
///         ShapeConfig.inset(
///           shape: GuidelineShape.rect,
///           insets: EdgeInsets.only(bottom: 20, right: 20),
///           size: Size(0.4, 0.1), // 40% width, 10% height
///           frameColor: Colors.red,
///         ),
///       ],
///     ),
///     // Date stamp
///     ShapeConfig.relativePosition(
///       shape: GuidelineShape.circle,
///       relativeOffset: Offset(0.9, 0.1),
///       size: Size(0.08, 0.08), // 8% of screen size
///       frameColor: Colors.green,
///     ),
///   ],
///   maskColor: Colors.black.withOpacity(0.6),
///   debugPaint: true, // Show debug info in development
/// )
/// ```
///
/// ## Key Features
///
/// * **Unified Masking**: All shapes share the same background mask
/// * **Individual Styling**: Each shape can have its own colors and properties
/// * **Nested Shapes**: Shapes can contain child shapes for complex layouts
/// * **Multiple Positioning**: Support for absolute, relative, centered, and inset positioning
/// * **Debug Support**: Visual debugging aids for development
///
/// See also:
/// * [ShapeConfig], for individual shape configuration
/// * [MultiShapeOverlayPainter], for rendering multi-shape overlays
/// * [GuidelineOverlayConfig], for single-shape overlays
class MultiShapeOverlayConfig {
  MultiShapeOverlayConfig({
    required this.shapes,
    this.maskColor = Colors.black54,
    this.debugPaint = false,
  }) : assert(shapes.isNotEmpty, 'At least one shape must be provided');

  /// The list of shapes to render in the overlay.
  ///
  /// This list contains all the shapes that will be rendered in the multi-shape
  /// overlay. Each shape can have its own properties, positioning, and even
  /// nested child shapes for complex layouts.
  ///
  /// The shapes are rendered in the order they appear in the list, with later
  /// shapes potentially overlapping earlier ones. The masking is applied
  /// collectively to all shapes, creating a unified background.
  ///
  /// Example:
  /// ```dart
  /// shapes: [
  ///   // Main document area (rendered first)
  ///   ShapeConfig(
  ///     shape: GuidelineShape.roundedRect,
  ///     bounds: Rect.fromLTWH(50, 100, 300, 200),
  ///     frameColor: Colors.white,
  ///   ),
  ///   // Overlay elements (rendered on top)
  ///   ShapeConfig.inset(
  ///     shape: GuidelineShape.rect,
  ///     insets: EdgeInsets.only(bottom: 20, right: 20),
  ///     frameColor: Colors.yellow,
  ///   ),
  /// ],
  /// ```
  ///
  /// Must contain at least one shape. An empty list will cause an assertion error.
  ///
  /// See also:
  /// * [ShapeConfig], for individual shape configuration
  final List<ShapeConfig> shapes;

  /// The color of the semi-transparent mask outside all shapes.
  ///
  /// This color is applied to the entire screen area except for the regions
  /// defined by the shapes. It creates a unified background that focuses
  /// attention on the capture areas while maintaining visibility of the
  /// camera preview.
  ///
  /// The mask is created by combining all shape paths and applying the
  /// inverse (difference) operation to the full screen area.
  ///
  /// Example:
  /// ```dart
  /// maskColor: Colors.black54,           // Standard dark mask
  /// maskColor: Colors.black.withOpacity(0.6), // Custom opacity
  /// maskColor: Colors.blue.withOpacity(0.3),  // Colored mask
  /// ```
  ///
  /// Defaults to `Colors.black54` for a standard semi-transparent dark mask.
  ///
  /// See also:
  /// * [MultiShapeOverlayPainter], for mask rendering implementation
  final Color maskColor;

  /// Whether to display debug information during development.
  ///
  /// When enabled in debug mode (`kDebugMode` is true), this displays additional
  /// visual information to help with development and debugging:
  /// * Shape boundaries and paths
  /// * Positioning guides
  /// * Child shape relationships
  /// * Masking areas
  ///
  /// Debug information is rendered in red with thin stroke lines and is only
  /// visible during development builds.
  ///
  /// Example:
  /// ```dart
  /// debugPaint: true,  // Show debug info in debug mode
  /// debugPaint: false, // No debug info (default)
  /// ```
  ///
  /// This is particularly useful when:
  /// * Designing complex multi-shape layouts
  /// * Debugging positioning issues
  /// * Understanding shape relationships
  /// * Verifying mask coverage
  ///
  /// Defaults to `false`.
  final bool debugPaint;

  /// Creates a copy of this MultiShapeOverlayConfig with the given fields replaced.
  MultiShapeOverlayConfig copyWith({
    List<ShapeConfig>? shapes,
    Color? maskColor,
    bool? debugPaint,
  }) {
    return MultiShapeOverlayConfig(
      shapes: shapes ?? this.shapes,
      maskColor: maskColor ?? this.maskColor,
      debugPaint: debugPaint ?? this.debugPaint,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MultiShapeOverlayConfig &&
        other.shapes == shapes &&
        other.maskColor == maskColor &&
        other.debugPaint == debugPaint;
  }

  @override
  int get hashCode {
    return Object.hash(shapes, maskColor, debugPaint);
  }
}
