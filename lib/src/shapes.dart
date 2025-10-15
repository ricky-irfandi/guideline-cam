import 'dart:ui';

import 'package:flutter/material.dart';

import '../guideline_cam.dart';

/// Creates a [Path] for the guideline overlay based on the configuration.
///
/// This function generates the geometric path that defines the shape and position
/// of the guideline overlay. It handles aspect ratio calculations, padding,
/// and different shape types to create the appropriate path for rendering.
///
/// ## Path Generation Process
///
/// 1. **Apply Padding**: Creates a padded rectangle from the available size
/// 2. **Calculate Aspect Ratio**: Adjusts dimensions to maintain specified ratio
/// 3. **Generate Shape Path**: Creates the appropriate path based on shape type
///
/// ## Aspect Ratio Handling
///
/// The function intelligently handles aspect ratio constraints:
/// * If current ratio > target ratio: Constrain by height, reduce width
/// * If current ratio < target ratio: Constrain by width, reduce height
/// * Circles ignore aspect ratio and are always perfectly round
///
/// ## Usage Example
///
/// ```dart
/// // Create a path for a rounded rectangle with ID card ratio
/// final config = GuidelineOverlayConfig(
///   shape: GuidelineShape.roundedRect,
///   aspectRatio: 1.586, // ID card ratio
///   padding: EdgeInsets.all(20.0),
///   borderRadius: 12.0,
/// );
///
/// final path = createGuidelinePath(Size(400, 800), config);
///
/// // Use the path with CustomPaint
/// CustomPaint(
///   painter: MyOverlayPainter(path),
///   size: Size(400, 800),
/// )
/// ```
///
/// ## Shape-Specific Behavior
///
/// * **Rectangle**: Creates a simple rectangular path
/// * **Rounded Rectangle**: Creates a rounded rectangle with specified border radius
/// * **Circle**: Creates a perfect circle (ignores aspect ratio)
/// * **Oval**: Creates an oval that respects aspect ratio
///
/// Parameters:
/// * [size] - The available size for the overlay (typically screen size)
/// * [config] - The configuration containing shape, aspect ratio, and padding
///
/// Returns a [Path] object that can be used for rendering the overlay shape.
///
/// See also:
/// * [GuidelineOverlayConfig], for configuration options
/// * [GuidelineShape], for available shape types
/// * [OverlayPainter], for using the generated path
Path createGuidelinePath(Size size, GuidelineOverlayConfig config) {
  final padded = Rect.fromLTRB(
    config.padding.left,
    config.padding.top,
    size.width - config.padding.right,
    size.height - config.padding.bottom,
  );

  Rect frameRect = padded;
  // Apply aspect ratio for rect/roundedRect/oval
  if (config.shape != GuidelineShape.circle && config.aspectRatio != null) {
    final targetRatio = config.aspectRatio!; // width / height
    final paddedWidth = padded.width;
    final paddedHeight = padded.height;
    final currentRatio = paddedWidth / paddedHeight;
    if (currentRatio > targetRatio) {
      // Constrain by height, reduce width
      final width = paddedHeight * targetRatio;
      final left = padded.center.dx - width / 2;
      frameRect = Rect.fromLTWH(left, padded.top, width, paddedHeight);
    } else if (currentRatio < targetRatio) {
      // Constrain by width, reduce height
      final height = paddedWidth / targetRatio;
      final top = padded.center.dy - height / 2;
      frameRect = Rect.fromLTWH(padded.left, top, paddedWidth, height);
    } else {
      frameRect = padded;
    }
  } else {
    frameRect = padded;
  }

  switch (config.shape) {
    case GuidelineShape.rect:
      return Path()..addRect(frameRect);
    case GuidelineShape.roundedRect:
      return Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            frameRect,
            Radius.circular(config.borderRadius),
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
