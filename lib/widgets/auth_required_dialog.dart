import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:homeo/controllers/e_login_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/pages/earn_login.dart';

/// 🔹 Gate helper for anything that requires sign-in (liking a service,
/// opening Profile, saving a favorite).
///
/// If the user is already signed in, [onAuthenticated] runs immediately
/// and this returns `true`. If not, the premium auth-required dialog is
/// shown instead and this returns `false` — the caller's action never
/// runs for a signed-out user.
bool requireAuth(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onAuthenticated,
}) {
  final auth = Get.find<AuthController>();

  if (auth.currentUser != null) {
    onAuthenticated();
    return true;
  }

  showAuthRequiredDialog(title: title, message: message);
  return false;
}

/// 🔹 Shows the premium "sign in to continue" dialog described in the
/// spec. [Cancel] just closes it; [Sign In] closes it and navigates to
/// the existing login page (`EarnLogin`) — no second auth system.
void showAuthRequiredDialog({required String title, required String message}) {
  final themeCtrl = Get.find<ThemeController>();

  Get.dialog(
    Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Dialog(
        backgroundColor: isDark ? const Color(0xFF15181C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E7C66).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF0E7C66),
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF16181C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: const Color(0xFF0E7C66),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.to(() => const EarnLogin());
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }),
    barrierDismissible: true,
  );
}
