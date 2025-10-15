import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guideline_cam/guideline_cam.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuidelineCamDemoApp());
}

class GuidelineCamDemoApp extends StatelessWidget {
  const GuidelineCamDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late GuidelineCamController _controller;
  Color _maskColor = Colors.black54;
  Color _frameColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _controller = GuidelineCamController();
    _controller.initialize();
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    try {
      final result = await _controller.capture();
      if (result != null) {
        if (mounted) {
          await _showCaptureDialog(
            file: result,
            capturedAt: DateTime.now(),
            lens: _controller.lensDirection,
          );
        }
      }
    } catch (e, st) {
      // You can also provide onError to GuidelineCamBuilder
      debugPrint('Capture error: $e\n$st');
    }
  }

  Future<void> _showCaptureDialog({
    required XFile file,
    required DateTime capturedAt,
    required CameraLensDirection lens,
  }) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 300,
                      height: 200,
                      child: Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Captured: ${capturedAt.toLocal()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text('Direction: ${lens.name}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab =
        _tabController.index != 2; // Hide on Overlay Builder tab
    return Scaffold(
      appBar: AppBar(
        title: const Text('GuidelineCam Example'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Custom Buttons'),
            Tab(text: 'Overlay Builder'),
            Tab(text: 'Multi/Nested'),
            Tab(text: 'Instruction'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BasicDemo(
              controller: _controller,
              onCaptured: (x) async {
                if (x != null) {
                  await _showCaptureDialog(
                    file: x,
                    capturedAt: DateTime.now(),
                    lens: _controller.lensDirection,
                  );
                }
              },
              maskColor: _maskColor,
              frameColor: _frameColor),
          _CustomButtonsDemo(
              controller: _controller,
              onCaptured: (x) async {
                if (x != null) {
                  await _showCaptureDialog(
                    file: x,
                    capturedAt: DateTime.now(),
                    lens: _controller.lensDirection,
                  );
                }
              },
              maskColor: _maskColor,
              frameColor: _frameColor),
          _OverlayBuilderDemo(
              controller: _controller,
              onCaptured: (x) async {
                if (x != null) {
                  await _showCaptureDialog(
                    file: x,
                    capturedAt: DateTime.now(),
                    lens: _controller.lensDirection,
                  );
                }
              },
              maskColor: _maskColor,
              frameColor: _frameColor),
          _MultiNestedDemo(
              controller: _controller,
              onCaptured: (x) async {
                if (x != null) {
                  await _showCaptureDialog(
                    file: x,
                    capturedAt: DateTime.now(),
                    lens: _controller.lensDirection,
                  );
                }
              },
              maskColor: _maskColor),
          _InstructionDemo(
              controller: _controller,
              onCaptured: (x) async {
                if (x != null) {
                  await _showCaptureDialog(
                    file: x,
                    capturedAt: DateTime.now(),
                    lens: _controller.lensDirection,
                  );
                }
              },
              maskColor: _maskColor,
              frameColor: _frameColor),
        ],
      ),
      bottomNavigationBar: _CapturePreviewBar(
        maskColor: _maskColor,
        frameColor: _frameColor,
        onMaskChanged: (c) => setState(() => _maskColor = c),
        onFrameChanged: (c) => setState(() => _frameColor = c),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: _capture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _CapturePreviewBar extends StatelessWidget {
  const _CapturePreviewBar({
    required this.maskColor,
    required this.frameColor,
    required this.onMaskChanged,
    required this.onFrameChanged,
  });

  final Color maskColor;
  final Color frameColor;
  final ValueChanged<Color> onMaskChanged;
  final ValueChanged<Color> onFrameChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        border: const Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        children: [
          _ColorChip(
            label: 'Mask',
            color: maskColor,
            onTap: () => _showPalette(context, maskColor, onMaskChanged,
                enableOpacity: true),
          ),
          const SizedBox(width: 12),
          _ColorChip(
            label: 'Frame',
            color: frameColor,
            onTap: () => _showPalette(context, frameColor, onFrameChanged),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Adjust mask and frame colors in real-time.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showPalette(
      BuildContext context, Color current, ValueChanged<Color> onPick,
      {bool enableOpacity = false}) {
    final List<Color> palette = <Color>[
      Colors.black54,
      Colors.black45,
      Colors.white,
      Colors.teal,
      Colors.blueAccent,
      Colors.amber,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.deepPurpleAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.cyan,
    ];
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        double opacity = enableOpacity ? current.a : 1.0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (enableOpacity) ...[
                      const Text('Mask Opacity'),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: opacity,
                              onChanged: (v) =>
                                  setModalState(() => opacity = v),
                              min: 0.0,
                              max: 0.9,
                              divisions: 9,
                              label: (opacity).toStringAsFixed(1),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child:
                                Text('${(opacity * 100).toStringAsFixed(0)}%'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final c in palette)
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              onPick(enableOpacity
                                  ? c.withValues(alpha: opacity)
                                  : c);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: enableOpacity
                                    ? c.withValues(alpha: opacity)
                                    : c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: c.computeLuminance() > 0.5
                                      ? Colors.black26
                                      : Colors.white24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(
      {required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _BasicDemo extends StatelessWidget {
  const _BasicDemo(
      {required this.controller,
      required this.onCaptured,
      required this.maskColor,
      required this.frameColor});

  final GuidelineCamController controller;
  final ValueChanged<XFile?> onCaptured;
  final Color maskColor;
  final Color frameColor;

  @override
  Widget build(BuildContext context) {
    return GuidelineCamBuilder(
      controller: controller,
      guideline: GuidelineOverlayConfig(
        shape: GuidelineShape.roundedRect,
        aspectRatio: 1.586,
        frameColor: frameColor,
        maskColor: maskColor,
        borderRadius: 40,
        cornerLength: 0,
      ),
      onCapture: (result) => onCaptured(result.file),
    );
  }
}

class _CustomButtonsDemo extends StatelessWidget {
  const _CustomButtonsDemo(
      {required this.controller,
      required this.onCaptured,
      required this.maskColor,
      required this.frameColor});

  final GuidelineCamController controller;
  final ValueChanged<XFile?> onCaptured;
  final Color maskColor;
  final Color frameColor;

  @override
  Widget build(BuildContext context) {
    return GuidelineCamBuilder(
      controller: controller,
      guideline: GuidelineOverlayConfig(
        shape: GuidelineShape.circle,
        frameColor: frameColor,
        maskColor: maskColor,
      ),
      flashButtonBuilder: (context, flashMode, onPressed) {
        return Container(
          decoration: BoxDecoration(
            color: flashMode == FlashMode.off ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onPressed,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      flashMode == FlashMode.off
                          ? Icons.flash_off
                          : Icons.flash_on,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      flashMode == FlashMode.off ? 'Flash OFF' : 'Flash ON',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      cameraSwitchButtonBuilder: (context, lensDirection, onPressed) {
        return FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.teal,
          child: Icon(
            lensDirection == CameraLensDirection.back
                ? Icons.camera_front
                : Icons.camera_rear,
          ),
        );
      },
      onCapture: (result) => onCaptured(result.file),
    );
  }
}

class _OverlayBuilderDemo extends StatelessWidget {
  const _OverlayBuilderDemo(
      {required this.controller,
      required this.onCaptured,
      required this.maskColor,
      required this.frameColor});

  final GuidelineCamController controller;
  final ValueChanged<XFile?> onCaptured;
  final Color maskColor;
  final Color frameColor;

  @override
  Widget build(BuildContext context) {
    return GuidelineCamBuilder(
      controller: controller,
      guideline: GuidelineOverlayConfig(
        shape: GuidelineShape.oval,
        aspectRatio: 0.75,
        padding: const EdgeInsets.all(80),
        frameColor: frameColor,
        maskColor: maskColor,
      ),
      overlayBuilder: (context, c) {
        return Stack(
          children: [
            Positioned(
              top: 50,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  final newMode = c.flashMode == FlashMode.off
                      ? FlashMode.always
                      : FlashMode.off;
                  await c.setFlashMode(newMode);
                },
                backgroundColor: c.flashMode == FlashMode.off
                    ? Colors.black54
                    : Colors.amber,
                child: Icon(
                  c.flashMode == FlashMode.off
                      ? Icons.flash_off
                      : Icons.flash_on,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  await c.switchCamera();
                },
                backgroundColor: Colors.black54,
                child: const Icon(Icons.switch_camera, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.large(
                  onPressed: () async {
                    final res = await c.capture();
                    onCaptured(res);
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'State: ${c.state.name.toUpperCase()}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      onCapture: (result) => onCaptured(result.file),
    );
  }
}

class _MultiNestedDemo extends StatelessWidget {
  const _MultiNestedDemo(
      {required this.controller,
      required this.onCaptured,
      required this.maskColor});

  final GuidelineCamController controller;
  final ValueChanged<XFile?> onCaptured;
  final Color maskColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Responsive rectangles/ovals using absolute bounds based on screen
        final faceOval = ShapeConfig(
          shape: GuidelineShape.oval,
          aspectRatio: 0.75,
          bounds: Rect.fromLTWH(
              width * 0.25, height * 0.10, width * 0.50, height * 0.4),
          frameColor: Colors.lightBlueAccent,
          strokeWidth: 3,
          cornerLength: 0,
        );
        final idCard = ShapeConfig(
          shape: GuidelineShape.roundedRect,
          bounds: Rect.fromLTWH(
              width * 0.15, height * 0.55, width * 0.70, height * 0.275),
          borderRadius: 16,
          frameColor: Colors.greenAccent,
          strokeWidth: 3,
          cornerLength: 0,
          children: [
            ShapeConfig.relativePosition(
              shape: GuidelineShape.rect,
              relativeOffset: const Offset(0.75, 0.5),
              size: const Size(0.3, 0.6),
              frameColor: Colors.white,
              strokeWidth: 2,
            ),
            ShapeConfig.inset(
              shape: GuidelineShape.roundedRect,
              cornerLength: 0,
              insets: const EdgeInsets.fromLTRB(16, 34, 16, 16),
              size: const Size(0.5, 0.2),
              frameColor: Colors.white,
              strokeWidth: 1.5,
            ),
          ],
        );

        return GuidelineCamBuilder(
          controller: controller,
          guideline: GuidelineOverlayConfig(
            shapes: [faceOval, idCard],
            maskColor: maskColor,
          ),
          onCapture: (result) => onCaptured(result.file),
        );
      },
    );
  }
}

class _InstructionDemo extends StatelessWidget {
  const _InstructionDemo(
      {required this.controller,
      required this.onCaptured,
      required this.maskColor,
      required this.frameColor});

  final GuidelineCamController controller;
  final ValueChanged<XFile?> onCaptured;
  final Color maskColor;
  final Color frameColor;

  @override
  Widget build(BuildContext context) {
    return GuidelineCamBuilder(
      controller: controller,
      guideline: GuidelineOverlayConfig(
        shape: GuidelineShape.roundedRect,
        aspectRatio: 1.586,
        frameColor: frameColor,
        maskColor: maskColor,
        showGrid: true,
        debugPaint: true,
      ),
      instructionBuilder: (context, state) {
        String message;
        Color color;
        switch (state) {
          case GuidelineState.initializing:
            message = 'Initializing camera...';
            color = Colors.orange;
            break;
          case GuidelineState.ready:
            message = 'Align the document within the frame.';
            color = Colors.green;
            break;
          case GuidelineState.capturing:
            message = 'Capturing... Hold steady!';
            color = Colors.blue;
            break;
          case GuidelineState.error:
            message = 'An error occurred. Please retry.';
            color = Colors.red;
            break;
        }
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
      onCapture: (result) => onCaptured(result.file),
    );
  }
}
