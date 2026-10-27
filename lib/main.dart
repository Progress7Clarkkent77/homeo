import 'package:homeo/controllers/contact_config_controller.dart';
//import 'package:homeo/controllers/chat_controller.dart';

import 'package:homeo/controllers/service_controller.dart';

import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/controllers/user_controller.dart';
import 'package:homeo/pages/home.dart';
//import 'package:homeo/controllers/user_presence_controller.dart';
import 'package:homeo/controllers/verified_controller.dart';
import 'package:homeo/pages/forgotpassword.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

//import 'package:the_splendid_market/login/forgot_password.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:homeo/controllers/account_controller.dart';

import 'package:homeo/controllers/e_login_controller.dart';

import 'package:homeo/pages/earn_login.dart';

import 'package:homeo/pages/onboarding.dart';
//import 'package:homeo/pages/policy.dart';
import 'package:homeo/pages/profile.dart';

//import 'package:the_splendid_market/productMarket/market/stores/market_desktop.dart';

//import 'package:the_splendid_market/productMarket/market/stores/market_tablet.dart';

//import 'package:the_splendid_market/vendor_dashboard/profile_settings.dart';

import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';

final FluroRouter router = FluroRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Web clean URL
  setPathUrlStrategy();

  // ✅ Initialize Firebase ONLY (keep startup light)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Run app immediately (VERY IMPORTANT for low RAM)
  runApp(const MyApp());

  // 🔥 Initialize heavy services AFTER UI loads
  _initBackgroundServices();
}

Future<void> _initBackgroundServices() async {
  await GetStorage.init();

  await Future.wait([
    // FCMService.init(),
    // LocalNotificationService.init(),
  ]);
}

/// 🔥 LAZY CONTROLLER INITIALIZATION
void initControllers() {
  Get.lazyPut(() => AuthController(), fenix: true);

  Get.lazyPut(() => AccountController(), fenix: true);

  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => VerifiedController(), fenix: true);

  Get.lazyPut(() => ServiceController(), fenix: true);

  // 🔥 Social / heavy controllers (NO permanent)

  Get.lazyPut(() => UserController(), fenix: true);
  //Get.lazyPut(() => ChatController(), fenix: true);

  Get.lazyPut(() => ContactConfigController(), fenix: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Color getMainColor(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDarkMode ? Colors.black : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controllers lazily
    initControllers();
    return GetMaterialApp(
      title: 'HOMEo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generator,
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboarding(),
        '/onboarding': (context) => const Onboarding(),
        '/home': (context) => Home(userName: '', userEmail: ''),
        '/login': (context) => const EarnLogin(),
        '/signup': (context) => const EarnSignUp(),
        '/forgotpassword': (context) => ForgotPassword(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
