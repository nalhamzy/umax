import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/ad_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  final svc = AdService();
  ref.onDispose(() {});
  return svc;
});
