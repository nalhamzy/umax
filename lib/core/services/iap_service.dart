import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_product_ids.dart';

typedef PurchaseSuccessCallback = void Function(String productId);

class IapProduct {
  final String id;
  final String title;
  final String price;
  final String description;
  const IapProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
  });
}

class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _products = {};
  bool _available = false;

  PurchaseSuccessCallback? onPurchaseSuccess;

  Future<void> initialize() async {
    if (kIsWeb) return;
    _available = await _iap.isAvailable();
    if (!_available) return;

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _sub?.cancel(),
      onError: (_) {},
    );

    try {
      final response = await _iap.queryProductDetails(IapProductIds.all);
      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
    } catch (e) {
      if (kDebugMode) print('IAP query failed: $e');
    }
  }

  bool get isAvailable => _available;

  IapProduct? product(String id) {
    final p = _products[id];
    if (p == null) return null;
    return IapProduct(
      id: p.id,
      title: p.title.isNotEmpty ? p.title : _fallbackTitle(id),
      price: p.price.isNotEmpty ? p.price : _fallbackPrice(id),
      description: p.description,
    );
  }

  List<IapProduct> allProducts() =>
      IapProductIds.all.map(product).whereType<IapProduct>().toList();

  Future<bool> purchase(String productId) async {
    if (!_available) return false;
    final details = _products[productId];
    if (details == null) return false;
    final param = PurchaseParam(productDetails: details);
    try {
      if (IapProductIds.subscriptions.contains(productId)) {
        return await _iap.buyNonConsumable(purchaseParam: param);
      } else {
        return await _iap.buyNonConsumable(purchaseParam: param);
      }
    } catch (e) {
      if (kDebugMode) print('IAP purchase failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (kDebugMode) print('IAP restore failed: $e');
    }
  }

  void _onPurchaseUpdates(List<PurchaseDetails> updates) {
    for (final p in updates) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        onPurchaseSuccess?.call(p.productID);
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  String _fallbackTitle(String id) {
    switch (id) {
      case IapProductIds.proWeekly: return 'UMAX Pro — Weekly';
      case IapProductIds.proMonthly: return 'UMAX Pro — Monthly';
      case IapProductIds.proYearly: return 'UMAX Pro — Yearly';
      case IapProductIds.lifetime: return 'UMAX Lifetime';
    }
    return id;
  }

  String _fallbackPrice(String id) {
    switch (id) {
      case IapProductIds.proWeekly: return '\$4.99';
      case IapProductIds.proMonthly: return '\$9.99';
      case IapProductIds.proYearly: return '\$39.99';
      case IapProductIds.lifetime: return '\$59.99';
    }
    return '';
  }

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
