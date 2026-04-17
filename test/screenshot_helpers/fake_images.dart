import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Lazy singleton temp dir, created once per test run.
Directory? _demoDir;
Directory _ensureDemoDir() {
  _demoDir ??= Directory.systemTemp.createTempSync('umax_demo_');
  return _demoDir!;
}

/// Generates a stylized placeholder "face" image via a pure-Dart PNG encoder
/// (no GPU calls — safe from widget tests). Returns the absolute file path.
Future<String> writeDemoFaceImage({
  required String filename,
  required List<Color> gradient,
  int size = 512,
}) async {
  final image = img.Image(width: size, height: size);

  // Diagonal gradient background
  final c1 = _rgba(gradient[0]);
  final c2 = _rgba(gradient[1]);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final t = ((x + y) / (size * 2)).clamp(0.0, 1.0);
      image.setPixelRgba(
        x, y,
        _lerp(c1[0], c2[0], t),
        _lerp(c1[1], c2[1], t),
        _lerp(c1[2], c2[2], t),
        255,
      );
    }
  }

  // Vignette (darken corners)
  final cx = size / 2, cy = size / 2;
  final maxD = math.sqrt(cx * cx + cy * cy);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final d = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy)) / maxD;
      if (d > 0.55) {
        final darken = ((d - 0.55) / 0.45).clamp(0.0, 1.0) * 0.5;
        final px = image.getPixel(x, y);
        image.setPixelRgba(
          x, y,
          (px.r * (1 - darken)).round(),
          (px.g * (1 - darken)).round(),
          (px.b * (1 - darken)).round(),
          255,
        );
      }
    }
  }

  // Hair cap (dark semi-circle in top half)
  final hairRadX = (size * 0.26).round();
  final hairRadY = (size * 0.17).round();
  final hairCy = (size * 0.30).round();
  _fillEllipse(image, size ~/ 2, hairCy, hairRadX, hairRadY, 30, 25, 40, 230);

  // Head (lighter oval)
  final headRadX = (size * 0.24).round();
  final headRadY = (size * 0.30).round();
  final headCy = (size * 0.44).round();
  _fillEllipse(image, size ~/ 2, headCy, headRadX, headRadY, 245, 235, 220, 230);

  // Shoulders (bottom wide oval)
  final shRadX = (size * 0.42).round();
  final shRadY = (size * 0.22).round();
  final shCy = (size * 0.95).round();
  _fillEllipse(image, size ~/ 2, shCy, shRadX, shRadY, 220, 210, 200, 200);

  final bytes = Uint8List.fromList(img.encodePng(image));
  final outPath = p.join(_ensureDemoDir().path, filename);
  File(outPath).writeAsBytesSync(bytes);
  return outPath;
}

List<int> _rgba(Color c) => [
      (c.r * 255).round(),
      (c.g * 255).round(),
      (c.b * 255).round(),
      (c.a * 255).round(),
    ];

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

void _fillEllipse(
  img.Image image,
  int cx,
  int cy,
  int rx,
  int ry,
  int r,
  int g,
  int b,
  int a,
) {
  for (int y = -ry; y <= ry; y++) {
    for (int x = -rx; x <= rx; x++) {
      final dx = x / rx;
      final dy = y / ry;
      if (dx * dx + dy * dy <= 1.0) {
        final px = cx + x;
        final py = cy + y;
        if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;
        // alpha blend
        final existing = image.getPixel(px, py);
        final aF = a / 255.0;
        image.setPixelRgba(
          px, py,
          (existing.r * (1 - aF) + r * aF).round(),
          (existing.g * (1 - aF) + g * aF).round(),
          (existing.b * (1 - aF) + b * aF).round(),
          255,
        );
      }
    }
  }
}
