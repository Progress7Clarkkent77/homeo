import 'package:homeo/controllers/e_login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late AuthController authController;

  final TextEditingController emailCtrl = TextEditingController();

  // 🔹 Focus node
  final FocusNode emailFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();

    authController = Get.put(AuthController());

    // 🔹 Listen for focus changes
    emailFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      logoSize = emailFocus.hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                /// 🔹 LOGO (same UI, dynamic size)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: logoSize,
                    height: logoSize,
                    child: Image.asset(
                      'assets/images/HOMEo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  'Forgot password?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                Text(
                  'Enter your email to reset your password',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                /// 🔹 CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /// EMAIL
                      TextField(
                        focusNode: emailFocus,
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: 'Enter your email',
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// RESET BUTTON
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: authController.isLoading.value
                                ? null
                                : () {
                                    if (emailCtrl.text.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Please enter your email',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    authController.sendPasswordResetEmail(
                                      emailCtrl.text.trim(),
                                    );
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Send Email',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// SIGN UP LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/signup'),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// FOOTER
                Text(
                  'powered by AFIA SPLENDID LTD',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
