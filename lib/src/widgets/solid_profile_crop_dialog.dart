/// Circular image crop dialog for profile pictures.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Tony Chen

library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Output resolution (width = height) for the cropped avatar PNG.

const int _cropOutputSize = 512;

/// Lets the user pan/zoom an image beneath a circular window and
/// returns the cropped result as PNG bytes when confirmed.

class SolidProfileCropDialog extends StatefulWidget {
  /// Raw image bytes (PNG or JPEG) to crop.

  final Uint8List imageBytes;

  const SolidProfileCropDialog({super.key, required this.imageBytes});

  /// Shows the dialog and returns cropped PNG bytes, or null if cancelled.

  static Future<Uint8List?> show(
    BuildContext context,
    Uint8List imageBytes,
  ) {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SolidProfileCropDialog(imageBytes: imageBytes),
    );
  }

  @override
  State<SolidProfileCropDialog> createState() =>
      _SolidProfileCropDialogState();
}

class _SolidProfileCropDialogState extends State<SolidProfileCropDialog> {
  final _repaintKey = GlobalKey();
  final _transformController = TransformationController();
  bool _isCropping = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cropAreaSize = 300.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crop Profile Picture',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: cropAreaSize,
              height: cropAreaSize,
              child: Stack(
                children: [
                  // Capturable layer — only the image, no overlay.
                  RepaintBoundary(
                    key: _repaintKey,
                    child: ClipRect(
                      child: SizedBox(
                        width: cropAreaSize,
                        height: cropAreaSize,
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.memory(
                            widget.imageBytes,
                            fit: BoxFit.cover,
                            width: cropAreaSize,
                            height: cropAreaSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Non-capturable circular overlay guide.
                  IgnorePointer(
                    child: CustomPaint(
                      size: const Size(cropAreaSize, cropAreaSize),
                      painter: _CircleOverlayPainter(
                        overlayColour:
                            theme.colorScheme.scrim.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pinch or scroll to zoom, drag to reposition',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isCropping ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isCropping ? null : _cropAndReturn,
                  child: _isCropping
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cropAndReturn() async {
    setState(() => _isCropping = true);

    try {
      final bytes = await _captureCircularPng();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (e) {
      debugPrint('Crop failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to crop image')),
        );
        setState(() => _isCropping = false);
      }
    }
  }

  /// Captures the RepaintBoundary, clips to a circle, and encodes as PNG.

  Future<Uint8List> _captureCircularPng() async {
    final boundary = _repaintKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;

    // Capture at sufficient resolution.
    final pixelRatio = _cropOutputSize / boundary.size.width;
    final rawImage = await boundary.toImage(pixelRatio: pixelRatio);

    // Draw the captured image clipped to a circle onto a new canvas.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = _cropOutputSize.toDouble();

    final circlePath = Path()
      ..addOval(Rect.fromLTWH(0, 0, size, size));
    canvas.clipPath(circlePath);
    canvas.drawImageRect(
      rawImage,
      Rect.fromLTWH(
        0,
        0,
        rawImage.width.toDouble(),
        rawImage.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, size, size),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final circularImage =
        await picture.toImage(_cropOutputSize, _cropOutputSize);
    final byteData =
        await circularImage.toByteData(format: ui.ImageByteFormat.png);

    rawImage.dispose();
    circularImage.dispose();

    return byteData!.buffer.asUint8List();
  }
}

/// Paints a semi-transparent overlay with a circular hole in the centre.

class _CircleOverlayPainter extends CustomPainter {
  final Color overlayColour;

  _CircleOverlayPainter({required this.overlayColour});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColour;
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    // Full rectangle minus the circle.
    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: centre, radius: radius));
    final overlayPath =
        Path.combine(PathOperation.difference, outerPath, circlePath);

    canvas.drawPath(overlayPath, paint);

    // Thin white circle border.
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleOverlayPainter oldDelegate) =>
      overlayColour != oldDelegate.overlayColour;
}
