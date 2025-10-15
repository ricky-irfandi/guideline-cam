import 'package:camera/camera.dart';

/// The result of a successful image capture operation.
///
/// This class contains all the information about a captured image, including
/// the file reference, timestamp, and camera metadata. It's provided to the
/// [GuidelineCamBuilder.onCapture] callback when an image is successfully captured.
///
/// ## Usage Example
///
/// ```dart
/// GuidelineCamBuilder(
///   controller: _controller,
///   onCapture: (result) {
///     // Access the captured image file
///     final imageFile = result.file;
///     print('Image saved to: ${imageFile.path}');
///
///     // Get capture metadata
///     print('Captured at: ${result.capturedAt}');
///     print('Camera lens: ${result.lens}');
///
///     // Process the image
///     _processCapturedImage(result);
///   },
/// )
///
/// Future<void> _processCapturedImage(GuidelineCaptureResult result) async {
///   // Read image bytes
///   final bytes = await result.file.readAsBytes();
///
///   // Save to gallery
///   await GallerySaver.saveImage(result.file.path);
///
///   // Upload to server
///   await _uploadImage(result.file);
///
///   // Navigate to preview
///   Navigator.push(
///     context,
///     MaterialPageRoute(
///       builder: (context) => ImagePreviewPage(result.file),
///     ),
///   );
/// }
/// ```
///
/// ## File Handling
///
/// The captured image is saved as a temporary file that you should process
/// or move to permanent storage. The file path is accessible through [file.path]
/// and the file can be read using [XFile.readAsBytes()] or [XFile.readAsString()].
///
/// See also:
/// * [XFile], for file operations
/// * [GuidelineCamBuilder.onCapture], for the capture callback
/// * [GuidelineCamController.capture()], for manual capture
class GuidelineCaptureResult {
  /// Creates a new capture result with the given properties.
  ///
  /// Parameters:
  /// * [file] - The captured image file
  /// * [capturedAt] - The timestamp when the image was captured
  /// * [lens] - The camera lens direction used for capture
  const GuidelineCaptureResult({
    required this.file,
    required this.capturedAt,
    required this.lens,
  });

  /// The captured image file.
  ///
  /// This [XFile] contains the captured image data and provides access to
  /// the file path, bytes, and other file operations. The file is typically
  /// saved in the device's temporary directory.
  ///
  /// Example:
  /// ```dart
  /// // Get file path
  /// final path = result.file.path;
  /// print('Image saved to: $path');
  ///
  /// // Read image bytes
  /// final bytes = await result.file.readAsBytes();
  /// final size = bytes.length;
  /// print('Image size: ${size} bytes');
  ///
  /// // Get file name
  /// final name = result.file.name;
  /// print('File name: $name');
  ///
  /// // Get file size
  /// final length = await result.file.length();
  /// print('File size: $length bytes');
  /// ```
  ///
  /// See also:
  /// * [XFile], for file operations and properties
  final XFile file;

  /// The timestamp when the image was captured.
  ///
  /// This [DateTime] represents the exact moment when the image capture
  /// was initiated. It's useful for organizing captured images, creating
  /// unique filenames, or tracking capture timing.
  ///
  /// Example:
  /// ```dart
  /// // Format timestamp for display
  /// final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(result.capturedAt);
  /// print('Captured at: $formatted');
  ///
  /// // Create unique filename
  /// final timestamp = result.capturedAt.millisecondsSinceEpoch;
  /// final filename = 'capture_$timestamp.jpg';
  ///
  /// // Check if capture was recent
  /// final now = DateTime.now();
  /// final difference = now.difference(result.capturedAt);
  /// if (difference.inSeconds < 5) {
  ///   print('Image captured just now');
  /// }
  /// ```
  ///
  /// See also:
  /// * [DateTime], for date and time operations
  final DateTime capturedAt;

  /// The camera lens direction used for the capture.
  ///
  /// This indicates which camera lens was active when the image was captured:
  /// * [CameraLensDirection.back] - Back/rear camera was used
  /// * [CameraLensDirection.front] - Front/selfie camera was used
  ///
  /// This information is useful for:
  /// * Organizing images by camera type
  /// * Applying different processing based on camera
  /// * UI feedback about which camera was used
  ///
  /// Example:
  /// ```dart
  /// // Check which camera was used
  /// if (result.lens == CameraLensDirection.back) {
  ///   print('Captured with back camera');
  ///   // Apply document processing
  /// } else {
  ///   print('Captured with front camera');
  ///   // Apply face processing
  /// }
  ///
  /// // Organize by camera type
  /// final folder = result.lens == CameraLensDirection.back
  ///     ? 'documents'
  ///     : 'selfies';
  /// await _moveToFolder(result.file, folder);
  /// ```
  ///
  /// See also:
  /// * [CameraLensDirection], for available lens directions
  /// * [GuidelineCamController.lensDirection], for current camera direction
  final CameraLensDirection lens;
}
