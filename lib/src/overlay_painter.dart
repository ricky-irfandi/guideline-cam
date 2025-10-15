import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guideline_cam/src/config.dart';
import 'package:guideline_cam/src/enums.dart';
import 'package:guideline_cam/src/shapes.dart';

/// A custom painter that renders single-shape guideline overlays.
///
/// This painter handles the rendering of guideline overlays with a single shape,
/// including the background mask, shape frame, optional grid, and corner indicators.
/// It works in conjunction with [createGuidelinePath] to generate the appropriate
/// geometric paths for different shape types.
///
/// ## Rendering Process
///
/// The painter follows this rendering sequence:
/// 1. **Background Mask**: Creates a semi-transparent mask outside the shape
/// 2. **Shape Frame**: Draws the main overlay boundary
/// 3. **Grid Lines**: Optionally draws a 3x3 alignment grid
/// 4. **Corner Indicators**: Optionally draws L-shaped corner guides
/// 5. **Debug Info**: Optionally shows debug boundaries in development
///
/// ## Usage Example
///
/// ```dart
/// CustomPaint(
///   painter: OverlayPainter(
///     GuidelineOverlayConfig(
///       shape: GuidelineShape.roundedRect,
///       aspectRatio: 1.586,
///       frameColor: Colors.white,
///       maskColor: Colors.black54,
///       showGrid: true,
///       cornerLength: 20.0,
///     ),
///   ),
///   size: size,
/// )
/// ```
///
/// ## Performance Considerations
///
/// * The painter is optimized for single shapes and performs well on most devices
/// * Complex shapes with high border radius values may impact performance
/// * Grid rendering adds minimal overhead
/// * Debug painting is only active in debug mode
///
/// ## Customization Options
///
/// The painter supports extensive customization through [GuidelineOverlayConfig]:
/// * **Shape Types**: Rectangle, rounded rectangle, circle, oval
/// * **Colors**: Frame color, mask color, grid color
/// * **Styling**: Stroke width, border radius, corner length
/// * **Features**: Grid display, corner indicators, debug mode
///
/// See also:
/// * [GuidelineOverlayConfig], for configuration options
/// * [MultiShapeOverlayPainter], for multi-shape overlays
/// * [createGuidelinePath], for path generation
class OverlayPainter extends CustomPainter {
  const OverlayPainter(this.config);

  /// The configuration that defines the overlay appearance and behavior.
  ///
  /// This configuration object contains all the properties needed to render
  /// the guideline overlay, including shape type, colors, dimensions, and
  /// optional features like grids and corner indicators.
  ///
  /// The painter uses this configuration to:
  /// * Determine the shape type and generate appropriate paths
  /// * Apply colors for frames, masks, and grids
  /// * Calculate dimensions and positioning
  /// * Enable/disable optional features
  ///
  /// See also:
  /// * [GuidelineOverlayConfig], for configuration options
  final GuidelineOverlayConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    final guidelinePath = createGuidelinePath(size, config);

    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final maskPath = Path.combine(
      PathOperation.difference,
      background,
      guidelinePath,
    );

    final maskPaint = Paint()..color = config.maskColor;
    canvas.drawPath(maskPath, maskPaint);

    final framePaint = Paint()
      ..color = config.frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.strokeWidth;
    canvas.drawPath(guidelinePath, framePaint);

    // Optional 3x3 grid inside rectangular/roundedRect/oval frames
    if (config.showGrid) {
      final gridPaint = Paint()
        ..color = config.frameColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final bounds = guidelinePath.getBounds();
      final dx = bounds.width / 3;
      final dy = bounds.height / 3;
      for (var i = 1; i < 3; i++) {
        // vertical lines
        final x = bounds.left + dx * i;
        canvas.drawLine(
            Offset(x, bounds.top), Offset(x, bounds.bottom), gridPaint);
        // horizontal lines
        final y = bounds.top + dy * i;
        canvas.drawLine(
            Offset(bounds.left, y), Offset(bounds.right, y), gridPaint);
      }
    }

    // Optional L-corners for rect/roundedRect
    if (config.cornerLength > 0 &&
        (config.shape == GuidelineShape.rect ||
            config.shape == GuidelineShape.roundedRect)) {
      final bounds = guidelinePath.getBounds();
      final cl = config.cornerLength;
      final cornerPaint = Paint()
        ..color = config.frameColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = config.strokeWidth;

      // Top-left
      canvas.drawLine(Offset(bounds.left, bounds.top),
          Offset(bounds.left + cl, bounds.top), cornerPaint);
      canvas.drawLine(Offset(bounds.left, bounds.top),
          Offset(bounds.left, bounds.top + cl), cornerPaint);

      // Top-right
      canvas.drawLine(Offset(bounds.right - cl, bounds.top),
          Offset(bounds.right, bounds.top), cornerPaint);
      canvas.drawLine(Offset(bounds.right, bounds.top),
          Offset(bounds.right, bounds.top + cl), cornerPaint);

      // Bottom-left
      canvas.drawLine(Offset(bounds.left, bounds.bottom - cl),
          Offset(bounds.left, bounds.bottom), cornerPaint);
      canvas.drawLine(Offset(bounds.left, bounds.bottom),
          Offset(bounds.left + cl, bounds.bottom), cornerPaint);

      // Bottom-right
      canvas.drawLine(Offset(bounds.right - cl, bounds.bottom),
          Offset(bounds.right, bounds.bottom), cornerPaint);
      canvas.drawLine(Offset(bounds.right, bounds.bottom - cl),
          Offset(bounds.right, bounds.bottom), cornerPaint);
    }

    if (config.debugPaint && kDebugMode) {
      final debugPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawPath(guidelinePath, debugPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.config.shape != config.shape ||
        oldDelegate.config.aspectRatio != config.aspectRatio ||
        oldDelegate.config.strokeWidth != config.strokeWidth ||
        oldDelegate.config.borderRadius != config.borderRadius ||
        oldDelegate.config.maskColor != config.maskColor ||
        oldDelegate.config.frameColor != config.frameColor ||
        oldDelegate.config.cornerLength != config.cornerLength ||
        oldDelegate.config.padding != config.padding ||
        oldDelegate.config.showGrid != config.showGrid ||
        oldDelegate.config.debugPaint != config.debugPaint;
  }
}
