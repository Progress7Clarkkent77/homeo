import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/pages/admin_services_page.dart';
import 'package:homeo/pages/home.dart' show kHomeoPrimary;

/// 🔹 Only this email may pass the admin gate below, whatever password is
/// typed alongside it. Everything else is rejected locally before a
/// Firebase Auth call is even attempted.
const String kHomeoAdminEmail = 'progressclarkkent@gmail.com';

/// 🔹 Premium "Admin Access" login gate, reached from the shield icon in
/// the Home header.
///
/// This is intentionally separate from `AuthController.login()`: that
/// method carries customer-only side effects (Terms-of-Use gate, FCM
/// token save, theme load, redirect to `/home`) that don't belong here.
/// Instead this page verifies the typed password directly against
/// Firebase Auth for [kHomeoAdminEmail] — the same Firebase project and
/// the same users AuthController manages — and, on success, opens
/// `AdminServicesPage` (which still independently checks
/// `e-users/{uid}.isAdmin` before showing any CRUD tools).
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    // 🔒 Restrict to the one allowed admin email before ever touching
    // Firebase Auth. A mismatched email is rejected instantly, with no
    // network call and nothing to rate-limit against.
    if (email.toLowerCase() != kHomeoAdminEmail.toLowerCase()) {
      setState(() {
        _loading = false;
        _error = 'This account is not authorized for admin access.';
      });
      return;
    }

    try {
      // Verifies the password against Firebase Auth for this exact
      // account — the same auth backend AuthController.login() uses,
      // just without any of its customer-facing side effects.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      Get.off(
        () => const AdminServicesPage(),
        transition: Transition.cupertino,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'user-not-found' ||
          'wrong-password' ||
          'invalid-credential' ||
          'invalid-email' => 'Incorrect email or password.',
          'too-many-requests' => 'Too many attempts. Please try again shortly.',
          'network-request-failed' =>
            'Network error. Check your connection and try again.',
          _ => 'Could not sign in. Please try again.',
        };
      });
    } catch (_) {
      setState(() => _error = 'Could not sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8F7),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: kHomeoPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: kHomeoPrimary,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Admin Access',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF14171A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in with the HOMEo admin account to manage services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _label('Email', isDark),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: _fieldDecoration(
                        isDark,
                        hint: 'admin@homeo.com',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Email is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _label('Password', isDark),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: _fieldDecoration(isDark, hint: '••••••••')
                          .copyWith(
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: isDark ? Colors.white38 : Colors.black38,
                                size: 20,
                              ),
                            ),
                          ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kHomeoPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _label(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white70 : Colors.black54,
    ),
  );

  InputDecoration _fieldDecoration(bool isDark, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : const Color(0xFFF3F4F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kHomeoPrimary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }
}
