import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guideline_cam/src/enums.dart';
import 'package:guideline_cam/src/multi_shape_config.dart';

/// A custom painter that renders complex multi-shape guideline overlays.
///
/// This painter handles the rendering of overlays containing multiple shapes with
/// different properties, positioning, and even nested child shapes. It provides
/// unified masking across all shapes while allowing individual shape customization.
///
/// ## Rendering Process
///
/// The painter follows this sophisticated rendering sequence:
/// 1. **Path Collection**: Gathers paths from all shapes and their children
/// 2. **Unified Masking**: Creates a single mask covering all shape areas
/// 3. **Shape Rendering**: Draws each shape with its individual properties
/// 4. **Recursive Children**: Renders nested child shapes recursively
/// 5. **Debug Visualization**: Optionally shows debug information
///
/// ## Key Features
///
/// * **Unified Masking**: All shapes share the same background mask
/// * **Individual Styling**: Each shape can have unique colors and properties
/// * **Nested Shapes**: Supports unlimited nesting of child shapes
/// * **Multiple Positioning**: Handles absolute, relative, centered, and inset positioning
/// * **Performance Optimized**: Efficient rendering for complex layouts
///
/// ## Usage Example
///
/// ```dart
/// CustomPaint(
///   painter: MultiShapeOverlayPainter(
///     MultiShapeOverlayConfig(
///       shapes: [
///         // Main document area
///         ShapeConfig(
///           shape: GuidelineShape.roundedRect,
///           bounds: Rect.fromLTWH(50, 100, 300, 200),
///           frameColor: Colors.white,
///           children: [
///             // Signature area
///             ShapeConfig.inset(
///               shape: GuidelineShape.rect,
///               insets: EdgeInsets.only(bottom: 20, right: 20),
///               size: Size(0.3, 0.2),
///               frameColor: Colors.yellow,
///             ),
///           ],
///         ),
///         // Date stamp
///         ShapeConfig.relativePosition(
///           shape: GuidelineShape.circle,
///           relativeOffset: Offset(0.9, 0.1),
///           size: Size(0.08, 0.08),
///           frameColor: Colors.green,
///         ),
///       ],
///       maskColor: Colors.black54,
///       debugPaint: false,
///     ),
///   ),
///   size: size,
/// )
/// ```
///
/// ## Positioning System
///
/// The painter supports four positioning modes for child shapes:
/// * **Absolute**: Fixed pixel coordinates
/// * **Relative**: Percentage-based positioning (0.0-1.0)
/// * **Centered**: Automatic centering within parent
/// * **Inset**: Margin-based positioning from edges
///
/// ## Performance Considerations
///
/// * Optimized for complex multi-shape layouts
/// * Recursive rendering may impact performance with deep nesting
/// * Debug mode adds minimal overhead
/// * Unified masking reduces rendering complexity
///
/// ## Advanced Features
///
/// * **Aspect Ratio Support**: Shapes can maintain specific proportions
/// * **Grid Rendering**: Individual shapes can show alignment grids
/// * **Corner Indicators**: L-shaped guides for rectangular shapes
/// * **Debug Mode**: Visual debugging aids for development
///
/// See also:
/// * [MultiShapeOverlayConfig], for configuration options
/// * [ShapeConfig], for individual shape configuration
/// * [OverlayPainter], for single-shape overlays
class MultiShapeOverlayPainter extends CustomPainter {
  const MultiShapeOverlayPainter(this.config);

  /// The configuration that defines the multi-shape overlay structure and appearance.
  ///
  /// This configuration object contains the list of shapes to render, along with
  /// global settings like mask color and debug mode. Each shape in the configuration
  /// can have its own properties, positioning, and nested child shapes.
  ///
  /// The painter uses this configuration to:
  /// * Determine which shapes to render and in what order
  /// * Apply global settings like mask color and debug mode
  /// * Handle shape positioning and nesting relationships
  /// * Generate appropriate rendering paths for each shape
  ///
  /// See also:
  /// * [MultiShapeOverlayConfig], for configuration options
  final MultiShapeOverlayConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    // Create combined path for all shapes (including children)
    final combinedPath = Path();
    for (final shapeConfig in config.shapes) {
      final shapePath = _createShapePath(shapeConfig, shapeConfig.bounds);
      combinedPath.addPath(shapePath, Offset.zero);

      // Add children paths recursively
      if (shapeConfig.children != null) {
        _addChildrenPaths(
            combinedPath, shapeConfig.children!, shapeConfig.bounds);
      }
    }

    // Create mask covering entire screen except shapes
    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final maskPath = Path.combine(
      PathOperation.difference,
      background,
      combinedPath,
    );

    // Draw unified mask
    final maskPaint = Paint()..color = config.maskColor;
    canvas.drawPath(maskPath, maskPaint);

    // Draw frames and grids for each shape (including children)
    for (final shapeConfig in config.shapes) {
      _drawShapeAndChildren(canvas, shapeConfig, shapeConfig.bounds);
    }

    // Debug paint
    if (config.debugPaint && kDebugMode) {
      final debugPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(combinedPath, debugPaint);
    }
  }

  /// Creates a path for a single shape configuration.
  Path _createShapePath(ShapeConfig shapeConfig, Rect bounds) {
    // Apply aspect ratio if specified
    Rect frameRect = bounds;
    if (shapeConfig.shape != GuidelineShape.circle &&
        shapeConfig.aspectRatio != null) {
      final targetRatio = shapeConfig.aspectRatio!; // width / height
      final currentRatio = bounds.width / bounds.height;

      if (currentRatio > targetRatio) {
        // Constrain by height, reduce width
        final width = bounds.height * targetRatio;
        final left = bounds.center.dx - width / 2;
        frameRect = Rect.fromLTWH(left, bounds.top, width, bounds.height);
      } else if (currentRatio < targetRatio) {
        // Constrain by width, reduce height
        final height = bounds.width / targetRatio;
        final top = bounds.center.dy - height / 2;
        frameRect = Rect.fromLTWH(bounds.left, top, bounds.width, height);
      }
    }

    switch (shapeConfig.shape) {
      case GuidelineShape.rect:
        return Path()..addRect(frameRect);
      case GuidelineShape.roundedRect:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              frameRect,
              Radius.circular(shapeConfig.borderRadius),
            ),
          );
      case GuidelineShape.circle:
        final center = frameRect.center;
        final radius = frameRect.width < frameRect.height
            ? frameRect.width / 2
            : frameRect.height / 2;
        return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
      case GuidelineShape.oval:
        return Path()..addOval(frameRect);
    }
  }

  /// Draws the frame for a single shape.
  void _drawShapeFrame(Canvas canvas, ShapeConfig shapeConfig, Rect bounds) {
    final shapePath = _createShapePath(shapeConfig, bounds);
    final framePaint = Paint()
      ..color = shapeConfig.frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = shapeConfig.strokeWidth;
    canvas.drawPath(shapePath, framePaint);
  }

  /// Draws a 3x3 grid inside a shape.
  void _drawGrid(Canvas canvas, ShapeConfig shapeConfig, Rect bounds) {
    final shapePath = _createShapePath(shapeConfig, bounds);
    final pathBounds = shapePath.getBounds();

    final gridPaint = Paint()
      ..color = shapeConfig.frameColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dx = pathBounds.width / 3;
    final dy = pathBounds.height / 3;

    for (var i = 1; i < 3; i++) {
      // Vertical lines
      final x = pathBounds.left + dx * i;
      canvas.drawLine(
        Offset(x, pathBounds.top),
        Offset(x, pathBounds.bottom),
        gridPaint,
      );
      // Horizontal lines
      final y = pathBounds.top + dy * i;
      canvas.drawLine(
        Offset(pathBounds.left, y),
        Offset(pathBounds.right, y),
        gridPaint,
      );
    }
  }

  /// Draws corner indicators for rectangular shapes.
  void _drawCorners(Canvas canvas, ShapeConfig shapeConfig, Rect bounds) {
    final shapePath = _createShapePath(shapeConfig, bounds);
    final pathBounds = shapePath.getBounds();
    final cl = shapeConfig.cornerLength;

    final cornerPaint = Paint()
      ..color = shapeConfig.frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = shapeConfig.strokeWidth;

    // Top-left
    canvas.drawLine(
      Offset(pathBounds.left, pathBounds.top),
      Offset(pathBounds.left + cl, pathBounds.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(pathBounds.left, pathBounds.top),
      Offset(pathBounds.left, pathBounds.top + cl),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(pathBounds.right - cl, pathBounds.top),
      Offset(pathBounds.right, pathBounds.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(pathBounds.right, pathBounds.top),
      Offset(pathBounds.right, pathBounds.top + cl),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(pathBounds.left, pathBounds.bottom - cl),
      Offset(pathBounds.left, pathBounds.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(pathBounds.left, pathBounds.bottom),
      Offset(pathBounds.left + cl, pathBounds.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(pathBounds.right - cl, pathBounds.bottom),
      Offset(pathBounds.right, pathBounds.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(pathBounds.right, pathBounds.bottom - cl),
      Offset(pathBounds.right, pathBounds.bottom),
      cornerPaint,
    );
  }

  /// Adds children paths recursively to the combined path.
  void _addChildrenPaths(
      Path combinedPath, List<ShapeConfig> children, Rect parentBounds) {
    for (final child in children) {
      final childBounds = _calculateChildBounds(child, parentBounds);
      final childPath = _createShapePath(child, childBounds);
      combinedPath.addPath(childPath, Offset.zero);

      // Recursively add grandchildren
      if (child.children != null) {
        _addChildrenPaths(combinedPath, child.children!, childBounds);
      }
    }
  }

  /// Calculates the absolute bounds for a child shape based on its positioning mode.
  Rect _calculateChildBounds(ShapeConfig child, Rect parentBounds) {
    switch (child.positioning) {
      case ShapePositioning.absolute:
        return child.bounds;

      case ShapePositioning.relative:
        if (child.relativeOffset == null) {
          return child.bounds;
        }
        final offset = child.relativeOffset!;
        final childSize = _calculateChildSize(child, parentBounds);
        final left = parentBounds.left +
            (parentBounds.width * offset.dx) -
            (childSize.width / 2);
        final top = parentBounds.top +
            (parentBounds.height * offset.dy) -
            (childSize.height / 2);
        return Rect.fromLTWH(left, top, childSize.width, childSize.height);

      case ShapePositioning.center:
        final childSize = _calculateChildSize(child, parentBounds);
        final left = parentBounds.center.dx - (childSize.width / 2);
        final top = parentBounds.center.dy - (childSize.height / 2);
        return Rect.fromLTWH(left, top, childSize.width, childSize.height);

      case ShapePositioning.inset:
        if (child.insets == null) {
          return child.bounds;
        }
        final insets = child.insets!;
        final childSize = _calculateChildSize(child, parentBounds);
        final left = parentBounds.left + insets.left;
        final top = parentBounds.top + insets.top;
        return Rect.fromLTWH(left, top, childSize.width, childSize.height);
    }
  }

  /// Calculates the size for a child shape.
  Size _calculateChildSize(ShapeConfig child, Rect parentBounds) {
    if (child.size != null) {
      final size = child.size!;
      // If size values are between 0.0 and 1.0, treat as percentage of parent
      if (size.width <= 1.0 && size.height <= 1.0) {
        return Size(
          parentBounds.width * size.width,
          parentBounds.height * size.height,
        );
      } else {
        // Absolute size
        return size;
      }
    }

    // Default to a reasonable size based on parent
    return Size(
      parentBounds.width * 0.3,
      parentBounds.height * 0.3,
    );
  }

  /// Draws a shape and all its children recursively.
  void _drawShapeAndChildren(
      Canvas canvas, ShapeConfig shapeConfig, Rect bounds) {
    // Draw the shape itself
    _drawShapeFrame(canvas, shapeConfig, bounds);

    if (shapeConfig.showGrid) {
      _drawGrid(canvas, shapeConfig, bounds);
    }

    if (shapeConfig.cornerLength > 0 &&
        (shapeConfig.shape == GuidelineShape.rect ||
            shapeConfig.shape == GuidelineShape.roundedRect)) {
      _drawCorners(canvas, shapeConfig, bounds);
    }

    // Draw children recursively
    if (shapeConfig.children != null) {
      for (final child in shapeConfig.children!) {
        final childBounds = _calculateChildBounds(child, bounds);
        _drawShapeAndChildren(canvas, child, childBounds);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MultiShapeOverlayPainter oldDelegate) {
    return oldDelegate.config != config;
  }
}
