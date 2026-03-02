// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_gradients.dart';

/// Shared screenshot / save utilities used by all report screens.
class ReportUtils {
  static Future<bool> requestMediaPermission() async {
    if (await Permission.photos.isGranted ||
        await Permission.storage.isGranted) {
      return true;
    }
    if (await Permission.photos.request().isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;
    return false;
  }

  /// Captures the widget bound to [reportKey], composites the app gradient
  /// behind it, and saves the result to the gallery under [fileName].
  static Future<void> captureAndSave(
    BuildContext context,
    GlobalKey reportKey,
    String fileName,
  ) async {
    final hasPermission = await requestMediaPermission();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
      }
      return;
    }

    try {
      final boundary = reportKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      final capturedImage = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      final width = capturedImage.width.toDouble();
      final height = capturedImage.height.toDouble();
      final rect = Rect.fromLTWH(0, 0, width, height);

      canvas.drawRect(
        rect,
        Paint()..shader = AppGradients.mainBackground.createShader(rect),
      );
      canvas.drawImage(capturedImage, Offset.zero, Paint());

      final finalImage = await recorder
          .endRecording()
          .toImage(capturedImage.width, capturedImage.height);

      final byteData =
          await finalImage.toByteData(format: ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: '${fileName}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result?['isSuccess'] == true
                  ? 'Report saved to gallery!'
                  : 'Failed to save report',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }
}
