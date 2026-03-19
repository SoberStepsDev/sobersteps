import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../l10n/strings.dart';
import '../services/purchase_service.dart';
import '../services/analytics_service.dart';

class PurchaseProvider extends ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();
  final AnalyticsService _analytics = AnalyticsService();

  bool _isPremium = false;
  /// Last known store product id (RevenueCat); null if free or unknown.
  String? _activeProductId;
  String _abVariant = 'A';
  DateTime? _installDate;

  bool get isPremium => _isPremium;
  String get abVariant => _abVariant;
  int get daysSinceInstall {
    if (_installDate == null) return 0;
    return DateTime.now().difference(_installDate!).inDays;
  }

  Future<void> init() async {
    await _purchaseService.init();
    _isPremium = await _purchaseService.checkPremium();
    final prefs = await SharedPreferences.getInstance();
    _activeProductId = prefs.getString('active_product_id');
    _abVariant = prefs.getString('ab_variant') ?? 'A';
    final installStr = prefs.getString('install_date');
    if (installStr != null) {
      _installDate = DateTime.parse(installStr);
    } else {
      _installDate = DateTime.now();
      await prefs.setString('install_date', _installDate!.toIso8601String());
    }
    notifyListeners();
  }

  Future<bool> purchase(String productId) async {
    final success = await _purchaseService.purchase(productId);
    if (success) {
      _isPremium = true;
      _activeProductId = productId;
      await SharedPreferences.getInstance().then((p) => p.setString('active_product_id', productId));
      _analytics.track('purchase_success', {'plan': productId});
      notifyListeners();
    }
    return success;
  }

  Future<bool> restore() async {
    _isPremium = await _purchaseService.restore();
    final prefs = await SharedPreferences.getInstance();
    if (_isPremium) {
      _activeProductId = prefs.getString('active_product_id');
    } else {
      _activeProductId = null;
    }
    notifyListeners();
    return _isPremium;
  }

  Future<void> refreshFromStore() async {
    await _purchaseService.init();
    _isPremium = await _purchaseService.checkPremium();
    final prefs = await SharedPreferences.getInstance();
    _activeProductId = prefs.getString('active_product_id');
    notifyListeners();
  }

  /// Localized subscription tier label for settings UI.
  String planDisplayLabel(BuildContext context) {
    if (!_isPremium) return S.t(context, 'planFree');
    final id = _activeProductId;
    if (id == AppConstants.monthlyProductId) return S.t(context, 'planMonthly');
    if (id == AppConstants.annualProductId) return S.t(context, 'planAnnual');
    if (id == AppConstants.lifetimeProductId) return S.t(context, 'planLifetime');
    if (id == AppConstants.familyProductId) return S.t(context, 'planFamily');
    return S.t(context, 'planPremiumActive');
  }

  bool hasShownUpsell(int milestoneDays) {
    return false; // Will check SharedPreferences in production
  }
}
