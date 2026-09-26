import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🔹 Centralized, configurable HOMEo contact info.
///
/// Per the spec: don't hard-code the WhatsApp/phone number throughout the
/// app. Numbers live in Firebase Remote Config (`homeo_whatsapp_number`,
/// `homeo_phone_number`) with safe fallback defaults, so HOMEo staff can
/// change the number without an app release.
class ContactConfigController extends GetxController {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Fallback numbers used until Remote Config has fetched, or if the
  /// fetch fails. Replace with HOMEo's real numbers before shipping.
  static const String _defaultWhatsAppNumber = '2349030323601';
  static const String _defaultPhoneNumber = '+2349030323601';

  final RxString whatsAppNumber = _defaultWhatsAppNumber.obs;
  final RxString phoneNumber = _defaultPhoneNumber.obs;
  final RxBool isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults({
        'homeo_whatsapp_number': _defaultWhatsAppNumber,
        'homeo_phone_number': _defaultPhoneNumber,
      });

      await _remoteConfig.fetchAndActivate();

      _applyRemoteValues();
    } catch (e) {
      if (kDebugMode) print('❌ Remote Config fetch error: $e');
      // Keep the fallback defaults already set above.
    } finally {
      isReady.value = true;
    }
  }

  void _applyRemoteValues() {
    final wa = _remoteConfig.getString('homeo_whatsapp_number');
    final phone = _remoteConfig.getString('homeo_phone_number');

    if (wa.isNotEmpty) whatsAppNumber.value = wa;
    if (phone.isNotEmpty) phoneNumber.value = phone;
  }

  /// 🔹 Opens a WhatsApp conversation with HOMEo, pre-filled with a
  /// professional enquiry message for [serviceName].
  Future<void> openWhatsApp({required String serviceName}) async {
    final message =
        'Hello HOMEo, I am interested in your $serviceName service. '
        'I would like to make an enquiry.';

    final digitsOnly = whatsAppNumber.value.replaceAll(RegExp(r'[^0-9]'), '');

    final uri = Uri.parse(
      'https://wa.me/$digitsOnly?text=${Uri.encodeComponent(message)}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Could not open WhatsApp',
        'Please make sure WhatsApp is installed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 🔹 Opens the device dialer with HOMEo's phone number pre-filled.
  Future<void> callHomeo() async {
    final uri = Uri(scheme: 'tel', path: phoneNumber.value);

    if (!await launchUrl(uri)) {
      Get.snackbar(
        'Could not open dialer',
        'Please dial ${phoneNumber.value} manually.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
