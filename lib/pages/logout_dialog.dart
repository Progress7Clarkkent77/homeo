import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kAccent = Color(0xFF0E7C66);
const Color _kDanger = Color(0xFFE5484D);

/// Full logout flow: premium white confirm dialog -> premium loading
/// dialog -> sign out -> close. The user stays on the page they were on
/// (no navigation), so on Home they simply land back on Home signed out.
Future<void> showLogoutFlow() async {
  final confirmed = await Get.dialog<bool>(
    const _LogoutConfirmDialog(),
    barrierColor: Colors.black.withOpacity(0.45),
  );
  if (confirmed != true) return;

  final done = ValueNotifier<bool>(false);
  Get.dialog(
    _LogoutProgressDialog(done: done),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
  );

  try {
    // Keep the loader visible long enough to feel deliberate, even when
    // sign-out itself is instant.
    await Future.wait([
      FirebaseAuth.instance.signOut(),
      Future.delayed(const Duration(milliseconds: 1400)),
    ]);
    done.value = true; // swap spinner for a check mark
    await Future.delayed(const Duration(milliseconds: 650));
    Get.back(); // close loader only — no page navigation
  } catch (_) {
    Get.back();
    Get.snackbar(
      'Logout failed',
      'Something went wrong. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  } finally {
    done.dispose();
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: Colors.black26,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kDanger.withOpacity(0.09),
              ),
              child: Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kDanger.withOpacity(0.14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: _kDanger,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log out?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111418),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to log out of HOMEo? You can sign back in anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.black.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111418),
                      side: BorderSide(color: Colors.black.withOpacity(0.12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kDanger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Log out',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutProgressDialog extends StatelessWidget {
  final ValueNotifier<bool> done;
  const _LogoutProgressDialog({required this.done});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shadowColor: Colors.black26,
        insetPadding: const EdgeInsets.symmetric(horizontal: 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
          child: ValueListenableBuilder<bool>(
            valueListenable: done,
            builder: (context, isDone, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutBack,
                      child: isDone
                          ? Container(
                              key: const ValueKey('done'),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kAccent.withOpacity(0.12),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: _kAccent,
                                size: 36,
                              ),
                            )
                          : const Padding(
                              key: ValueKey('loading'),
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                strokeCap: StrokeCap.round,
                                valueColor: AlwaysStoppedAnimation(_kAccent),
                                backgroundColor: Color(0x1A0E7C66),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isDone ? 'Logged out' : 'Logging you out…',
                      key: ValueKey(isDone),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111418),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDone ? 'See you soon.' : 'Just a moment',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
