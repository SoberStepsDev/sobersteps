import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> init() async {
    // OneSignal initialization placeholder
    // OneSignal.initialize(AppConstants.oneSignalAppId);
    debugPrint('[NotificationService] initialized (stub)');
  }

  Future<bool> requestPermission() async {
    // OneSignal.shared.promptUserForPushNotificationPermission()
    debugPrint('[NotificationService] permission requested');
    return true;
  }

  void setUserId(String userId) {
    debugPrint('[NotificationService] setUserId $userId');
  }

  void setUserData(Map<String, dynamic> data) {
    debugPrint('[NotificationService] setUserData $data');
  }

  void logout() {
    debugPrint('[NotificationService] logout');
  }
}
