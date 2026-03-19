import 'package:flutter/foundation.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;
  PurchaseService._();

  bool _isPremium = false; // ignore: prefer_final_fields
  bool get isPremium => _isPremium;

  Future<void> init() async {
    // RevenueCat initialization placeholder
    // await Purchases.configure(PurchasesConfiguration(AppConstants.revenueCatApiKey));
    debugPrint('[PurchaseService] initialized (stub)');
  }

  Future<bool> checkPremium() async {
    // Placeholder: check RevenueCat entitlements
    // final info = await Purchases.getCustomerInfo();
    // _isPremium = info.entitlements.all['premium']?.isActive ?? false;
    return _isPremium;
  }

  Future<bool> purchase(String productId) async {
    // Placeholder: purchase via RevenueCat
    debugPrint('[PurchaseService] purchase $productId');
    return false;
  }

  Future<bool> restore() async {
    debugPrint('[PurchaseService] restore');
    return _isPremium;
  }

  /// RevenueCat / store restore entry point (alias for [restore]).
  Future<bool> restorePurchases() => restore();

  void setUserId(String userId) {
    debugPrint('[PurchaseService] setUserId $userId');
  }
}
