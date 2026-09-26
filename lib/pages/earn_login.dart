import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeo/controllers/account_controller.dart';

import 'package:homeo/controllers/e_login_controller.dart';

class EarnLogin extends StatefulWidget {
  const EarnLogin({super.key});

  @override
  State<EarnLogin> createState() => _EarnLoginState();
}

class _EarnLoginState extends State<EarnLogin> {
  final AccountController accountController = Get.put(
    AccountController(),
    permanent: true,
  ); //Get.put(AccountController());
  // late Blockchain blockchainInstance;
  late AuthController authController;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // 🔹 Focus nodes
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();
    accountController.toggleBalanceVisibility();

    // blockchainInstance = Blockchain();
    authController = Get.put(AuthController());

    // 🔹 Listen for focus changes
    emailFocus.addListener(_handleFocusChange);
    passwordFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final hasFocus = emailFocus.hasFocus || passwordFocus.hasFocus;

    setState(() {
      logoSize = hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                  'Welcome back',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                // Text(
                //   'Sign in to continue on spiiiq',
                //   style: TextStyle(
                //     fontSize: 13,
                //     color: Colors.black54,
                //   ),
                // ),
                Column(
                  children: const [
                    Text(
                      'Continue with your Textido account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sign in to continue to HOMEo.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                            borderSide: BorderSide(
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

                      const SizedBox(height: 16),

                      /// PASSWORD
                      Obx(
                        () => TextField(
                          focusNode: passwordFocus,
                          controller: passwordCtrl,
                          obscureText: !authController.isPasswordVisible.value,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                            ),
                            hintText: 'Enter 6-digit password',
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  authController.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/forgotpassword'),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.65),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// LOGIN BUTTON
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
                                    authController.login(
                                      emailCtrl.text.trim(),
                                      passwordCtrl.text.trim(),
                                    );
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Log in',
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

                /// SIGN UP
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

////////////////////////////////////////
///

// class _EarnLoginState extends State<EarnLogin> {
//   final AccountController accountController = Get.put(AccountController());
//   late Blockchain blockchainInstance;
//   late AuthController authController;

//   final TextEditingController emailCtrl = TextEditingController();
//   final TextEditingController passwordCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     accountController.toggleBalanceVisibility();

//     blockchainInstance = Blockchain();
//     authController = Get.put(AuthController(blockchainInstance));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 /// 🔹 LOGO
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(22),
//                   child: Image.asset(
//                     'assets/images/spiiiq Logo.jpeg',
//                     width: 96,
//                     height: 96,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 /// 🔹 TITLE
//                 const Text(
//                   'Welcome back',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   'Sign in to continue on spiiiq',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.black54,
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 /// 🔹 CARD
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 30,
//                         offset: const Offset(0, 14),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       /// EMAIL
//                       TextField(
//                         controller: emailCtrl,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             // Black border when focused
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(color: Colors.black, width: 2),
//                           ),
//                           prefixIcon: const Icon(Icons.email),
//                           labelText: 'Email',
//                           labelStyle: TextStyle(
//                             color: Colors.black.withOpacity(0.65),
//                           ),
//                           hintText: 'Enter your email',
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       /// PASSWORD
//                       Obx(() => TextField(
//                             controller: passwordCtrl,
//                             obscureText:
//                                 !authController.isPasswordVisible.value,
//                             keyboardType: TextInputType.number,
//                             maxLength: 6,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 // Black border when focused
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     BorderSide(color: Colors.black, width: 2),
//                               ),
//                               prefixIcon: const Icon(Icons.lock),
//                               labelText: 'Password',
//                               labelStyle: TextStyle(
//                                 color: Colors.black.withOpacity(0.65),
//                               ),
//                               hintText: 'Enter 6-digit password',
//                               counterText: '',
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   authController.isPasswordVisible.value
//                                       ? Icons.visibility
//                                       : Icons.visibility_off,
//                                 ),
//                                 onPressed:
//                                     authController.togglePasswordVisibility,
//                               ),
//                             ),
//                           )),

//                       const SizedBox(height: 10),

//                       /// FORGOT PASSWORD
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () => Get.toNamed('/forgotpassword'),
//                           child: Text(
//                             'Forgot password?',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.black.withOpacity(0.65),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       /// LOGIN BUTTON
//                       Obx(() => SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.black,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                               onPressed: authController.isLoading.value
//                                   ? null
//                                   : () {
//                                       authController.login(
//                                         emailCtrl.text.trim(),
//                                         passwordCtrl.text.trim(),
//                                       );
//                                     },
//                               child: authController.isLoading.value
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : Text(
//                                       'Log in',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           )),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 22),

//                 /// SIGN UP
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Don't have an account?",
//                       style: TextStyle(fontSize: 13),
//                     ),
//                     TextButton(
//                       onPressed: () => Get.toNamed('/signup'),
//                       child: Text(
//                         'Sign up',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black.withOpacity(0.65),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 /// FOOTER
//                 Text(
//                   'A text-first social platform',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.black45,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Import your AuthController

// Make sure to import your AuthController

// class EarnSignUp extends StatefulWidget {
//   const EarnSignUp({super.key});

//   @override
//   _EarnSignUpState createState() => _EarnSignUpState();
// }

// class _EarnSignUpState extends State<EarnSignUp> {
//   late Blockchain blockchainInstance;
//   late AuthController _authController;

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool isHovered = false;

//   @override
//   void initState() {
//     super.initState();

//     blockchainInstance = Blockchain(); // ✅ Initialize here
//     _authController = Get.put(
//         AuthController(blockchainInstance)); // ✅ Pass Blockchain instance
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color mainColor =
//         getMainColor(context); // Replace with your actual method to get color

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           // height: 700,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/whiteb1.jpg'),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Padding(
//                 //   padding: const EdgeInsets.all(8.0),
//                 //   child: Row(
//                 //     children: [
//                 //       IconButton(
//                 //         icon: const Icon(Icons.arrow_back_ios),
//                 //         onPressed: () {
//                 //           Get.back();
//                 //         },
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//                 //SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     height: 600,
//                     width: 400,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           color: Colors.transparent,
//                           width: 350,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Get An Account',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: mainColor,
//                                   ),
//                                 ),
//                                 SizedBox(height: 20),
//                                 TextField(
//                                   controller: _nameController,
//                                   keyboardType: TextInputType.text,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(
//                                         RegExp(r"^[a-zA-Z\s]+$")),
//                                     LengthLimitingTextInputFormatter(20),
//                                   ],
//                                   decoration: InputDecoration(
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       // Black border when focused
//                                       borderRadius: BorderRadius.circular(12),
//                                       borderSide: BorderSide(
//                                           color: Colors.black, width: 2),
//                                     ),
//                                     prefixIcon: const Icon(Icons.person),
//                                     labelText: 'Name',
//                                     labelStyle: TextStyle(
//                                       color: Colors.black.withOpacity(0.65),
//                                     ),
//                                     hintText: 'Enter your name',
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//                                 TextField(
//                                   controller: _emailController,
//                                   keyboardType: TextInputType.emailAddress,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.deny(
//                                         RegExp(r'\s')),
//                                   ],
//                                   decoration: InputDecoration(
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       // Black border when focused
//                                       borderRadius: BorderRadius.circular(12),
//                                       borderSide: BorderSide(
//                                           color: Colors.black, width: 2),
//                                     ),
//                                     prefixIcon: const Icon(Icons.email),
//                                     labelText: 'Email',
//                                     labelStyle: TextStyle(
//                                       color: Colors.black.withOpacity(0.65),
//                                     ),
//                                     hintText: 'Enter your email',
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//                                 Obx(
//                                   () => TextField(
//                                     controller: _passwordController,
//                                     obscureText: !_authController
//                                         .isPasswordVisible.value,
//                                     keyboardType: TextInputType.number,
//                                     inputFormatters: [
//                                       FilteringTextInputFormatter.digitsOnly,
//                                       LengthLimitingTextInputFormatter(6),
//                                     ],
//                                     decoration: InputDecoration(
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         // Black border when focused
//                                         borderRadius: BorderRadius.circular(12),
//                                         borderSide: BorderSide(
//                                             color: Colors.black, width: 2),
//                                       ),
//                                       prefixIcon: const Icon(Icons.lock),
//                                       labelText: 'Password',
//                                       labelStyle: TextStyle(
//                                         color: Colors.black.withOpacity(0.65),
//                                       ),
//                                       hintText: 'Enter 6-digit password',
//                                       counterText: '',
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _authController
//                                                   .isPasswordVisible.value
//                                               ? Icons.visibility
//                                               : Icons.visibility_off,
//                                         ),
//                                         onPressed: _authController
//                                             .togglePasswordVisibility,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 40),
//                         // Container(
//                         //   height: 20,
//                         //   width: 250,
//                         //   decoration: BoxDecoration(
//                         //     color: mainColor.withOpacity(0.2),
//                         //     borderRadius: BorderRadius.circular(10),
//                         //   ),
//                         //   child: Center(
//                         //     child: Text(
//                         //       'Sign Up and Get 1 CWX',
//                         //       style: TextStyle(
//                         //         fontWeight: FontWeight.bold,
//                         //         color: mainColor,
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                         SizedBox(height: 5),
//                         Center(
//                           child: SizedBox(
//                             width: 180,
//                             child: MouseRegion(
//                               onEnter: (_) => setState(() => isHovered = true),
//                               onExit: (_) => setState(() => isHovered = false),
//                               child: Obx(() => ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 15),
//                                       backgroundColor: isHovered
//                                           ? mainColor.withOpacity(0.9)
//                                           : mainColor,
//                                       shadowColor:
//                                           Colors.black.withOpacity(0.4),
//                                       elevation: 10,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                     ),
//                                     child: _authController.isLoading.value
//                                         ? const CircularProgressIndicator(
//                                             color: Colors.white,
//                                           )
//                                         : const Text(
//                                             'Sign Up',
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                     onPressed: () async {
//                                       // Check if the name, email, and password fields are not empty
//                                       if (_nameController.text.isNotEmpty &&
//                                           _emailController.text.isNotEmpty &&
//                                           _passwordController.text.isNotEmpty) {
//                                         // Call the signup method with name, email, and password
//                                         await _authController.signup(
//                                           _nameController.text.trim(),
//                                           _emailController.text.trim(),
//                                           _passwordController.text.trim(),
//                                         );
//                                       } else {
//                                         Get.snackbar("Error",
//                                             "Please fill in all fields correctly.");
//                                       }
//                                     },
//                                   )),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Already have an account?',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Get.toNamed("/login");
//                                 },
//                                 child: Text(
//                                   'Login',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black.withOpacity(0.65),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'spiiiq',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   //color: Colors.black,
//                                   color: Colors.black.withOpacity(0.65),
//                                 ),
//                               ),
//                               Text(
//                                 'A text-first social platform',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   height: 180,
//                   color: Colors.transparent,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class EarnSignUp extends StatefulWidget {
  const EarnSignUp({super.key});

  @override
  State<EarnSignUp> createState() => _EarnSignUpState();
}

class _EarnSignUpState extends State<EarnSignUp> {
  // late Blockchain blockchainInstance;
  late AuthController authController;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  /// 🔹 Optional — a friend's 6-digit referral code.
  final TextEditingController referCodeCtrl = TextEditingController();

  // 🔹 Focus nodes
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode referCodeFocus = FocusNode();

  // 🔹 Logo size
  double logoSize = 96;

  @override
  void initState() {
    super.initState();
    // blockchainInstance = Blockchain();
    authController = Get.put(AuthController());

    // 🔹 Listen for focus changes
    nameFocus.addListener(_handleFocusChange);
    emailFocus.addListener(_handleFocusChange);
    passwordFocus.addListener(_handleFocusChange);
    referCodeFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final hasFocus =
        nameFocus.hasFocus ||
        emailFocus.hasFocus ||
        passwordFocus.hasFocus ||
        referCodeFocus.hasFocus;

    setState(() {
      logoSize = hasFocus ? 20 : 96;
    });
  }

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    referCodeCtrl.dispose();
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
                  'Create account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                Text(
                  'Join HOMEo and get started',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

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
                      /// NAME
                      TextField(
                        focusNode: nameFocus,
                        controller: nameCtrl,
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
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: 'Enter your name',
                        ),
                      ),

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 16),

                      /// PASSWORD
                      Obx(
                        () => TextField(
                          focusNode: passwordFocus,
                          controller: passwordCtrl,
                          obscureText: !authController.isPasswordVisible.value,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
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
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                            ),
                            hintText: 'Enter 6-digit password',
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  authController.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// REFERRAL CODE (optional)
                      TextField(
                        focusNode: referCodeFocus,
                        controller: referCodeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
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
                          prefixIcon: const Icon(Icons.card_giftcard),
                          labelText: 'Referral code (optional)',
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                          ),
                          hintText: "Friend's 6-digit code",
                          counterText: '',
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SIGN UP BUTTON
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
                                : () async {
                                    if (nameCtrl.text.isEmpty ||
                                        emailCtrl.text.isEmpty ||
                                        passwordCtrl.text.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'All fields are required',
                                      );
                                      return;
                                    }

                                    await authController.signup(
                                      nameCtrl.text.trim(),
                                      emailCtrl.text.trim(),
                                      passwordCtrl.text.trim(),
                                    );
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Create account',
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

                /// LOGIN LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/login'),
                      child: Text(
                        'Log in',
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
