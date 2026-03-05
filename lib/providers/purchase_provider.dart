import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';
import '../services/analytics_service.dart';

class PurchaseProvider extends ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();
  final AnalyticsService _analytics = AnalyticsService();

  bool _isPremium = false;
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
      _analytics.track('purchase_success', {'plan': productId});
      notifyListeners();
    }
    return success;
  }

  Future<bool> restore() async {
    _isPremium = await _purchaseService.restore();
    notifyListeners();
    return _isPremium;
  }

  bool hasShownUpsell(int milestoneDays) {
    return false; // Will check SharedPreferences in production
  }
}
