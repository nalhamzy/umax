@Tags(['screenshot'])
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umax/core/constants/app_colors.dart';
import 'package:umax/core/constants/theme.dart';
import 'package:umax/core/services/storage_service.dart';
import 'package:umax/providers/scan_provider.dart';
import 'package:umax/providers/storage_provider.dart';
import 'package:umax/screens/history_screen.dart';
import 'package:umax/screens/home_screen.dart';
import 'package:umax/screens/paywall_screen.dart';
import 'package:umax/screens/result_screen.dart';
import 'package:umax/screens/routine_screen.dart';

import 'screenshot_helpers/seed.dart';

/// Generates store-ready screenshots directly via RepaintBoundary.toImage(),
/// bypassing the golden-file framework (which pumpAndSettle's and hangs on
/// lingering timers from plugin providers). Run with:
///
///     flutter test --tags=screenshot test/screenshot_test.dart
///
/// Output: `store_assets/ios/*.png` and `store_assets/android/*.png`.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadBundledFonts();
  });

  final sizes = <String, _Canvas>{
    // iPhone 6.9" (iPhone 15/16 Pro Max) — required by App Store
    'ios': const _Canvas(subdir: 'ios', physical: Size(1290, 2796), dpr: 3.0),
    // iPad Pro 13" (2024) — required when app supports iPad
    'ipad':
        const _Canvas(subdir: 'ipad', physical: Size(2064, 2752), dpr: 2.0),
    // Android tall phone (Pixel-class)
    'android':
        const _Canvas(subdir: 'android', physical: Size(1080, 2400), dpr: 3.0),
  };

  final scenes = <String, _Scene>{
    '01_home': _Scene(build: (_) => const HomeScreen()),
    '02_result': _Scene(build: (_) => const ResultScreen(), seedCurrent: true),
    '03_routine':
        _Scene(build: (_) => const RoutineScreen(), seedCurrent: true),
    '04_history': _Scene(build: (_) => const HistoryScreen()),
    '05_paywall': _Scene(build: (_) => const PaywallScreen()),
  };

  for (final sizeEntry in sizes.entries) {
    final platform = sizeEntry.key;
    final canvas = sizeEntry.value;
    group('$platform screenshots', () {
      for (final sceneEntry in scenes.entries) {
        final name = sceneEntry.key;
        final scene = sceneEntry.value;
        testWidgets(name, (tester) async {
          await _capture(
            tester,
            canvas: canvas,
            scene: scene,
            outPath: _outputPath(canvas.subdir, '$name.png'),
          );
        }, timeout: const Timeout(Duration(minutes: 2)));
      }
    });
  }
}

class _Canvas {
  final String subdir;
  final Size physical;
  final double dpr;
  const _Canvas({
    required this.subdir,
    required this.physical,
    required this.dpr,
  });
}

class _Scene {
  final WidgetBuilder build;
  final bool seedCurrent;
  _Scene({required this.build, this.seedCurrent = false});
}

String _outputPath(String subdir, String filename) {
  // Test CWD when `flutter test` runs is the package root.
  final dir = p.join(Directory.current.path, 'store_assets', subdir);
  Directory(dir).createSync(recursive: true);
  return p.join(dir, filename);
}

Future<void> _capture(
  WidgetTester tester, {
  required _Canvas canvas,
  required _Scene scene,
  required String outPath,
}) async {
  // Sizing
  await tester.binding.setSurfaceSize(canvas.physical);
  tester.view.physicalSize = canvas.physical;
  tester.view.devicePixelRatio = canvas.dpr;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await seedDemoState();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  final captureKey = GlobalKey();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: _Host(
        captureKey: captureKey,
        scene: scene,
      ),
    ),
  );

  // Layout + postFrameCallback seeds + rebuild.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));

  // Capture directly via the RepaintBoundary we attached.
  final bytes = await _captureBoundary(tester, captureKey, canvas.dpr);
  File(outPath).writeAsBytesSync(bytes);
}

Future<void> _loadBundledFonts() async {
  Future<void> loadFamily(String family, String ttfPath) async {
    final bytes = File(ttfPath).readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
  final base = Directory.current.path;
  await loadFamily('Inter', '$base/assets/fonts/Inter-Regular.ttf');
  await loadFamily('SpaceGrotesk', '$base/assets/fonts/SpaceGrotesk-Regular.ttf');
  await loadFamily('MaterialIcons', '$base/assets/fonts/MaterialIcons-Regular.otf');
}

Future<Uint8List> _captureBoundary(
  WidgetTester tester,
  GlobalKey key,
  double pixelRatio,
) async {
  late Uint8List result;
  await tester.runAsync(() async {
    final ro = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await ro.toImage(pixelRatio: pixelRatio);
    final bd = await image.toByteData(format: ui.ImageByteFormat.png);
    result = Uint8List.fromList(bd!.buffer.asUint8List());
    image.dispose();
  });
  return result;
}

class _Host extends ConsumerStatefulWidget {
  final GlobalKey captureKey;
  final _Scene scene;
  const _Host({required this.captureKey, required this.scene});
  @override
  ConsumerState<_Host> createState() => _HostState();
}

class _HostState extends ConsumerState<_Host> {
  @override
  void initState() {
    super.initState();
    if (widget.scene.seedCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final scans = ref.read(scanProvider);
        if (scans.history.isNotEmpty && scans.current == null) {
          ref.read(scanProvider.notifier).selectHistoric(scans.history.first);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMAX',
      debugShowCheckedModeBanner: false,
      theme: buildUmaxTheme(),
      home: RepaintBoundary(
        key: widget.captureKey,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: Builder(builder: widget.scene.build),
        ),
      ),
    );
  }
}
