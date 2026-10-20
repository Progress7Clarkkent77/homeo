import 'package:homeo/controllers/ads_controller.dart';
import 'package:homeo/controllers/balance_controller.dart';
import 'package:homeo/controllers/contact_config_controller.dart';
//import 'package:homeo/controllers/chat_controller.dart';
import 'package:homeo/controllers/moderation_controller.dart';
//import 'package:spiiiq/controllers/market_controller.dart';
import 'package:homeo/controllers/referral_controller.dart';
import 'package:homeo/controllers/r_controller.dart';
import 'package:homeo/controllers/service_controller.dart';
import 'package:homeo/controllers/status_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/controllers/user_controller.dart';
import 'package:homeo/pages/home.dart';
//import 'package:homeo/controllers/user_presence_controller.dart';
import 'package:homeo/controllers/verified_controller.dart';
import 'package:homeo/pages/forgotpassword.dart';
import 'package:homeo/services/fcm_background.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  //Get.lazyPut(() => CurrencyController(), fenix: true);
  //  Get.lazyPut(() => WithdrawController1(), fenix: true);
  //Get.lazyPut(() => BlocksController(), fenix: true);
  Get.lazyPut(() => ModerationController(), fenix: true);
  //Get.lazyPut(() => HistoryController(), fenix: true);
  //Get.lazyPut(() => PbcMarketController(), fenix: true);
  //  Get.lazyPut(() => TradeController(), fenix: true);
  //Get.lazyPut(() => LiquidityController(), fenix: true);
  Get.lazyPut(() => AccountController(), fenix: true);
  //  Get.lazyPut(() => AddMoneyController(), fenix: true);
  //Get.lazyPut(() => ExchangeController(), fenix: true);
  //Get.lazyPut(() => TokenDataController(), fenix: true);
  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => VerifiedController(), fenix: true);
  Get.lazyPut(() => RController(), fenix: true);
  Get.lazyPut(() => ReferController(), fenix: true);
  Get.lazyPut(() => ServiceController(), fenix: true);

  // 🔥 Social / heavy controllers (NO permanent)
  //Get.lazyPut(() => UserPresenceController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
  //Get.lazyPut(() => ChatController(), fenix: true);
  Get.lazyPut(() => StatusController(), fenix: true);
  //Get.put(StatusController(), permanent: true);
  //Get.put(MarketController(), permanent: true);
  //Get.lazyPut(() => MarketController(), fenix: true);
  //Get.put(StatusController1(), permanent: true);
  //Get.lazyPut(() => StatusController(), fenix: true);
  //Get.lazyPut(() => ChannelController(), fenix: true);
  Get.lazyPut(() => AdsController(), fenix: true);
  Get.lazyPut(() => AvailableBalanceController(), fenix: true);
  Get.lazyPut(() => ContactConfigController(), fenix: true);

  // 🔹 HotGist category controllers — lazy so each is only created
  // when its screen is first opened, and disposed (listeners
  // cancelled via onClose) when no longer referenced.
  //Get.lazyPut(() => ComedyGistController(), fenix: true);
  //Get.lazyPut(() => PoliticsGistController(), fenix: true);
  //Get.lazyPut(() => SportsGistController(), fenix: true);

  //Get.lazyPut(() => SellController(), fenix: true);
  //Get.lazyPut(() => ChannelProfileController(), fenix: true);
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
        // '/preference': (context) => Preference(),
        // '/walletdetails': (context) => WalletDetails(),
        // '/selectaddress': (context) => SelectAddress(),
        // '/send': (context) => Send(walletAddress: ''),
        // '/lwallet': (context) => LocalWallet(),
        // '/host': (context) => HostPxp(),
        // '/vote': (context) => Vote(),
        // '/join': (context) => JoinPxp(exchangeDetails: {}),
        // '/receive': (context) => Receive(),
        // '/cowriexd': (context) => CowriexDetails(),
        // '/chartd': (context) => ChartDetails(),
        // '/earnhome': (context) => EarnHome(),
        '/home': (context) => Home(userName: '', userEmail: ''),
        // '/history': (context) => TransactionHistory(),
        // '/documentation': (context) => Documentation(),
        '/login': (context) => const EarnLogin(),
        '/signup': (context) => const EarnSignUp(),
        '/forgotpassword': (context) => ForgotPassword(),
        '/profile': (context) => ProfileScreen(),
        //'/policy': (context) => spiiiqrPolicyScreen(),
        // '/verify': (context) => Verify(mnemonic: ''),
        // '/confirm': (context) => Confirm(words: []),
        // '/forgotc': (context) => ForgotConfirm(words: []),
        // '/changepassword': (context) => ChangePassword(),
        // '/addmoney': (context) => AddMoney(),
        // '/withdraw': (context) => Withdraw(),
        // '/exchange': (context) => Exchange(),
        // '/pXp': (context) => Pxp(),
        // '/pXphome': (context) {
        //   final authController = Get.find<AuthController>();
        //   final user = authController.currentUser;
        //   if (user == null) return const EarnLogin();
        //   return ExchangeUI(userId: user.uid);
        // },
        // '/blocks': (context) => Blocks(),
        // '/cowriexdetails': (context) => CowriexDetails(),
        // '/buy': (context) => Buy(),
        // '/sell': (context) => Sell(),
        // '/tokendata': (context) => TokenData(),
        // '/walletaddress': (context) => WalletAddress(),
        // '/publickey': (context) => PublicKey(),
        // '/whitepaper': (context) => Documentation(),
        // '/mine': (context) => Mine(),
        // '/answer': (context) => Answer(),
      },
    );
  }
}
