@Tags(['assets'])
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

/// One-off generator for static brand assets.
///
///     flutter test --tags=assets test/generate_assets_test.dart
///
/// Produces:
/// - assets/icon/icon_source.png   (1024×1024)
/// - store_assets/play/icon_512.png (512×512)
/// - store_assets/play/feature.png  (1024×500)
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Future<void> loadFamily(String family, String ttfPath) async {
      final bytes = File(ttfPath).readAsBytesSync();
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
    final base = Directory.current.path;
    await loadFamily('Inter', '$base/assets/fonts/Inter-Regular.ttf');
    await loadFamily('SpaceGrotesk', '$base/assets/fonts/SpaceGrotesk-Regular.ttf');
  });

  testWidgets('icon 1024', (tester) async {
    await _writeAppIcon(tester, size: 1024,
        outPath: _resolve('assets/icon/icon_source.png'));
  });

  testWidgets('icon 512', (tester) async {
    await _writeAppIcon(tester, size: 512,
        outPath: _resolve('store_assets/play/icon_512.png'));
  });

  testWidgets('feature 1024x500', (tester) async {
    await _writeFeatureGraphic(tester,
        outPath: _resolve('store_assets/play/feature.png'));
  });
}

String _resolve(String rel) {
  final out = p.join(Directory.current.path, rel);
  Directory(p.dirname(out)).createSync(recursive: true);
  return out;
}

Future<void> _writeAppIcon(
  WidgetTester tester, {
  required double size,
  required String outPath,
}) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(Size(size, size));
  tester.view.physicalSize = Size(size, size);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: _UmaxIcon(size: size),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final bytes = await _capture(tester, key, 1.0);
  File(outPath).writeAsBytesSync(bytes);
}

Future<void> _writeFeatureGraphic(
  WidgetTester tester, {
  required String outPath,
}) async {
  const w = 1024.0;
  const h = 500.0;
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(const Size(w, h));
  tester.view.physicalSize = const Size(w, h);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: const _UmaxFeature(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final bytes = await _capture(tester, key, 1.0);
  File(outPath).writeAsBytesSync(bytes);
}

Future<Uint8List> _capture(
  WidgetTester tester,
  GlobalKey key,
  double pixelRatio,
) async {
  late Uint8List bytes;
  await tester.runAsync(() async {
    final ro = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await ro.toImage(pixelRatio: pixelRatio);
    final bd = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = Uint8List.fromList(bd!.buffer.asUint8List());
    image.dispose();
  });
  return bytes;
}

class _UmaxIcon extends StatelessWidget {
  final double size;
  const _UmaxIcon({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7B61FF), // accent purple
            Color(0xFFFF3D71), // accent coral
          ],
        ),
      ),
      child: CustomPaint(
        painter: _UPainter(),
        size: Size(size, size),
      ),
    );
  }
}

class _UPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    // Soft radial highlight
    canvas.drawCircle(
      Offset(s.width * 0.3, s.height * 0.25),
      s.width * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
            center: Offset(s.width * 0.3, s.height * 0.25),
            radius: s.width * 0.55)),
    );

    // Stylized "U" — two tall bars joined by a curve.
    final w = s.width;
    final paint = Paint()..color = Colors.white;
    final strokeW = w * 0.11;

    final left = w * 0.28;
    final right = w * 0.72;
    final top = s.height * 0.26;
    final bottom = s.height * 0.74;

    // Left bar
    final rrLeft = RRect.fromLTRBR(
        left - strokeW / 2, top, left + strokeW / 2, bottom - strokeW * 0.5,
        Radius.circular(strokeW / 2));
    canvas.drawRRect(rrLeft, paint);

    // Right bar
    final rrRight = RRect.fromLTRBR(
        right - strokeW / 2, top, right + strokeW / 2, bottom - strokeW * 0.5,
        Radius.circular(strokeW / 2));
    canvas.drawRRect(rrRight, paint);

    // Bottom arc
    final arcRect = Rect.fromLTRB(
        left - strokeW / 2, bottom - strokeW * 2.5,
        right + strokeW / 2, bottom + strokeW * 0.5);
    canvas.drawArc(
        arcRect, 0, 3.1415926,
        false,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeW);

    // Small chevron accent ("level up" mark) top-right
    final accentPath = Path()
      ..moveTo(w * 0.70, s.height * 0.17)
      ..lineTo(w * 0.82, s.height * 0.17)
      ..lineTo(w * 0.76, s.height * 0.09)
      ..close();
    canvas.drawPath(
      accentPath,
      Paint()..color = const Color(0xFFFFD700),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UmaxFeature extends StatelessWidget {
  const _UmaxFeature();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0B14), Color(0xFF1E1535), Color(0xFF391042)],
        ),
      ),
      child: Stack(
        children: [
          // Big faded U on the left
          Positioned(
            left: -60,
            top: 60,
            width: 400,
            height: 380,
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _UPainter(),
                size: const Size(400, 380),
              ),
            ),
          ),
          // App icon chip on left
          Positioned(
            left: 70,
            top: 170,
            width: 160,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const _UmaxIcon(size: 160),
            ),
          ),
          // Title + subtitle right side
          Positioned(
            left: 270,
            right: 40,
            top: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UMAX',
                  style: const TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI face rating · 30-day glow-up plan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDCD3FF),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xFFFFC75F),
                      Color(0xFFFF8A3D),
                    ]),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'PRIVATE · ON-DEVICE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
