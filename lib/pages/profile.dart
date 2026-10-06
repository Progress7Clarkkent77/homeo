import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:homeo/controllers/account_controller.dart';
import 'package:homeo/controllers/e_login_controller.dart';
import 'package:homeo/controllers/referral_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/controllers/verified_controller.dart';
import 'package:homeo/pages/avatar_screen.dart';

const Color _kPrimary = Color(0xFF0E7C66);
const Color _kPrimaryDark = Color(0xFF0A5C4C);
const Color _kDanger = Color(0xFFE5484D);

// ─────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController themeCtrl = Get.find();
  final AccountController accountCtrl = Get.find();

  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();

    // 🔹 FIX for "name / email / avatar empty until hot restart":
    // AccountController is created lazily and may do its one-time fetch
    // before Firebase has a signed-in user (fresh login, or the session
    // still restoring on a cold start). So the profile asks for the data
    // itself every time it opens, and again whenever the signed-in user
    // changes, instead of trusting a fetch that may have already run
    // against a null user.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _refresh();
    });
  }

  void _refresh() {
    if (FirebaseAuth.instance.currentUser == null) return;
    accountCtrl.fetchUserInfo();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      final bg = isDark ? Colors.black : const Color(0xFFF7F8F7);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: isDark ? Colors.white : const Color(0xFF111418),
            ),
          ),
        ),
        body: RefreshIndicator(
          color: _kPrimary,
          onRefresh: () async => _refresh(),
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: const [
              ProfileHeader(),
              SizedBox(height: 18),
              ReferralCard(),
              SizedBox(height: 18),
              DeleteCard(),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final accountCtrl = Get.find<AccountController>();
  final verifiedCtrl = Get.find<VerifiedController>();
  final themeCtrl = Get.find<ThemeController>();

  // After a few seconds without data we stop showing the skeleton so a
  // genuinely empty profile doesn't shimmer forever.
  bool _gaveUpWaiting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _gaveUpWaiting = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      final authUser = FirebaseAuth.instance.currentUser;

      // Controller value first, FirebaseAuth as an instant fallback so
      // the email is never blank for a signed-in user.
      final name = accountCtrl.userName.value.trim().isNotEmpty
          ? accountCtrl.userName.value.trim()
          : (authUser?.displayName ?? '').trim();
      final email = accountCtrl.userEmail.value.trim().isNotEmpty
          ? accountCtrl.userEmail.value.trim()
          : (authUser?.email ?? '').trim();
      final avatar = accountCtrl.avatarName.value;

      final loading = name.isEmpty && !_gaveUpWaiting;
      final subtle = isDark ? Colors.white60 : Colors.black54;

      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16191D) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.07),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Brand cover
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 96,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kPrimary, _kPrimaryDark],
                    ),
                  ),
                ),
              ),
              // Avatar overlaps the cover (48 = half the avatar height)
              Padding(
                padding: const EdgeInsets.only(top: 48, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF16191D)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: 'profile_avatar',
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: const Color(0xFFEAF4F1),
                                backgroundImage: avatar.isNotEmpty
                                    ? AssetImage('assets/images/$avatar.png')
                                    : null,
                                child: avatar.isEmpty
                                    ? (loading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.4,
                                                color: _kPrimary,
                                              ),
                                            )
                                          : Text(
                                              name.isEmpty
                                                  ? '?'
                                                  : name[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: _kPrimary,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ))
                                    : null,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 0,
                            child: Material(
                              color: _kPrimary,
                              shape: CircleBorder(
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF16191D)
                                      : Colors.white,
                                  width: 3,
                                ),
                              ),
                              elevation: 2,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () =>
                                    Get.to(() => const AvatarSelectionScreen()),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (loading) ...[
                        _SkeletonBar(width: 140, height: 18, isDark: isDark),
                        const SizedBox(height: 10),
                        _SkeletonBar(width: 190, height: 28, isDark: isDark),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  name.isEmpty ? 'HOMEo User' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111418),
                                  ),
                                ),
                              ),
                              if (verifiedCtrl.isVerified.value) ...[
                                const SizedBox(width: 6),
                                Image.asset(
                                  'assets/images/verified.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : _kPrimary.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: 15,
                                  color: subtle,
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: subtle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23272D) : const Color(0xFFEDEEF0),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Referral
// ─────────────────────────────────────────────────────────────────────────

class ReferralCard extends StatefulWidget {
  const ReferralCard({super.key});

  @override
  State<ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<ReferralCard> {
  final themeCtrl = Get.find<ThemeController>();
  final ReferController referController = Get.put(ReferController());
  final AuthController authController = Get.find<AuthController>();

  String _code = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReferCode();
  }

  // 🔹 Loaded once in initState — previously this ran inside build(),
  // so it re-hit Firestore on every rebuild.
  Future<void> _loadReferCode() async {
    final uid = authController.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final code = await authController.ensureReferCode(uid);
      if (mounted) setState(() => _code = code);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not load your referral code. Pull to refresh and try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      return _SectionCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: _kPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite Friends',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111418),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share HOMEo with your referral code',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF3F6F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _kPrimary.withOpacity(0.25),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: _loading
                    ? _SkeletonBar(width: 110, height: 16, isDark: isDark)
                    : Text(
                        _code.isEmpty ? '—' : _code,
                        style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : _kPrimaryDark,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Referral Code'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: referController.copyReferralText,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Delete account
// ─────────────────────────────────────────────────────────────────────────

class DeleteCard extends StatelessWidget {
  const DeleteCard({super.key});

  void _showDeleteAccountDialog(AccountController accountCtrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kDanger.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: _kDanger,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete account?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111418),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will permanently delete your account and all associated '
                'data. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kDanger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        Get.back(); // close dialog first
                        try {
                          await accountCtrl.deleteAccount();
                        } catch (_) {
                          Get.snackbar(
                            'Error',
                            'Could not delete account. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final accountCtrl = Get.find<AccountController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      return _SectionCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danger zone',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: _kDanger.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Deleting your account removes your data permanently.',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                label: const Text('Delete Account'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: _kDanger,
                  side: BorderSide(color: _kDanger.withOpacity(0.45)),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _showDeleteAccountDialog(accountCtrl),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared card shell
// ─────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _SectionCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16191D) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
