import 'package:homeo/controllers/account_controller.dart';
import 'package:homeo/controllers/balance_controller.dart';
import 'package:homeo/controllers/e_login_controller.dart';
//import 'package:homeo/controllers/market_controller.dart';
import 'package:homeo/controllers/referral_controller.dart';

import 'package:homeo/controllers/status_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/controllers/verified_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:homeo/pages/avatar_screen.dart';
// import 'package:homeo/pages/comment_screen.dart';
// import 'package:homeo/pages/pay_history.dart';
// import 'package:homeo/pages/withdrawal_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final ThemeController themeCtrl = Get.find();

  final AccountController accountCtrl = Get.find();

  final VerifiedController verifiedCtrl = Get.find();

  final StatusController statusCtrl = Get.find();

  final AuthController authCtrl = Get.find();

  final ReferController referCtrl = Get.put(ReferController());

  final AvailableBalanceController balanceCtrl = Get.put(
    AvailableBalanceController(),
  );

  final ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: isDark ? Colors.black : Colors.white,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            "Profile",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            //verifiedCtrl.waitForUserAndListen();

            accountCtrl.fetchUserInfo();

            balanceCtrl.listenToBalance();
          },
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: const [
              /// HEADER
              ProfileHeader(),

              //SizedBox(height: 22),

              /// STATS
              // ProfileStats(),
              SizedBox(height: 22),

              /// WALLET
              //WalletCard(),

              //SizedBox(height: 22),

              /// VERIFIED
              // VerificationBanner(),
              SizedBox(height: 22),

              /// REFERRAL
              ReferralCard(),

              SizedBox(height: 24),

              /// POSTS / PRODUCTS
              // ProfileTabs(),
              DeleteCard(),
              SizedBox(height: 20),

              /// BODY
              // UserPosts(),
            ],
          ),
        ),
      );
    });
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final accountCtrl = Get.find<AccountController>();

    final verifiedCtrl = Get.find<VerifiedController>();

    final themeCtrl = Get.find<ThemeController>();
    //final ReferController referController = Get.put(ReferController());

    void showVerificationDialog() {
      final isDark = themeCtrl.isDarkMode.value;

      Get.dialog(
        Dialog(
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get Verified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Verification unlocks higher visibility and trust for 30 days on SpiiiQ. '
                  'Verified users are prioritized across posts, comments, and channels, '
                  'helping quality content reach more people.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                _benefitRow('Up to 3× more exposure on posts', isDark),
                const SizedBox(height: 8),
                _benefitRow(
                  'Priority placement for posts and comments',
                  isDark,
                ),
                const SizedBox(height: 8),
                _benefitRow('A visible verified badge for credibility', isDark),
                const SizedBox(height: 8),
                _benefitRow('Increased chances of reactions', isDark),
                const SizedBox(height: 14),
                Text(
                  'Verification does not change reward rates. '
                  'Higher earnings come from increased visibility and engagement.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Get.back();

                          verifiedCtrl.verifyWithPaystack();
                        },
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
      );
    }

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark ? const Color(0xff151515) : Colors.white,
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .35 : .08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: "profile_avatar",
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: accountCtrl.avatarName.value.isNotEmpty
                        ? AssetImage(
                            "assets/images/${accountCtrl.avatarName.value}.png",
                          )
                        : null,
                    child: accountCtrl.avatarName.value.isEmpty
                        ? Text(
                            accountCtrl.userName.value.isEmpty
                                ? "?"
                                : accountCtrl.userName.value[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: -2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Get.to(() => const AvatarSelectionScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    accountCtrl.userName.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (verifiedCtrl.isVerified.value) ...[
                  const SizedBox(width: 6),
                  Image.asset(
                    "assets/images/verified.png",
                    width: 20,
                    height: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              accountCtrl.userEmail.value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey : Colors.black54,
              ),
            ),
            const SizedBox(height: 14),

            // Row(
            //   children: [
            //     Expanded(
            //       child: verifiedCtrl.isVerified.value
            //           ? Container(
            //               height: 46,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(16),
            //                 color: Colors.blue.withOpacity(.12),
            //                 border: Border.all(color: Colors.blue),
            //               ),
            //               child: Center(
            //                 child: Text(
            //                   "${verifiedCtrl.daysLeft.value} Days Left",
            //                   style: const TextStyle(
            //                     color: Colors.blue,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ),
            //             )
            //           : ElevatedButton.icon(
            //               onPressed: () {
            //                 showVerificationDialog();
            //               },
            //               icon: Icon(
            //                 Icons.verified_outlined,
            //                 color: isDark ? Colors.white : Colors.black,
            //               ),
            //               label: const Text(
            //                 "Get Verified",
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //                 softWrap: false,
            //               ),
            //               style: ElevatedButton.styleFrom(
            //                 elevation: 0,
            //                 backgroundColor: Colors.black,
            //                 foregroundColor: Colors.white,
            //                 minimumSize: const Size.fromHeight(46),
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(16),
            //                 ),
            //               ),
            //             ),
            //     ),
            //     const SizedBox(width: 14),
            //     Expanded(
            //       child: OutlinedButton.icon(
            //         onPressed: () async {
            //           const String xUrl =
            //               'https://x.com/Textido?t=Ynwl6eeqlaALeIKjoKYhBg&s=09';

            //           final Uri url = Uri.parse(xUrl);

            //           try {
            //             final launched = await launchUrl(
            //               url,
            //               mode: LaunchMode.externalApplication,
            //             );

            //             if (!launched) {
            //               Get.snackbar(
            //                 'Error',
            //                 'Could not open X',
            //                 snackPosition: SnackPosition.BOTTOM,
            //                 backgroundColor: isDark
            //                     ? Colors.grey.shade900
            //                     : Colors.white,
            //                 colorText: isDark ? Colors.white : Colors.black,
            //               );
            //             }
            //           } catch (e) {
            //             Get.snackbar(
            //               'Error',
            //               'Could not open X',
            //               snackPosition: SnackPosition.BOTTOM,
            //               backgroundColor: isDark
            //                   ? Colors.grey.shade900
            //                   : Colors.white,
            //               colorText: isDark ? Colors.white : Colors.black,
            //             );
            //           }
            //         },
            //         icon: Icon(
            //           Icons.open_in_new,
            //           size: 18,
            //           color: isDark ? Colors.white : Colors.black,
            //         ),
            //         label: const Text("Follow X"),
            //         style: OutlinedButton.styleFrom(
            //           minimumSize: const Size.fromHeight(46),
            //           foregroundColor: isDark ? Colors.white : Colors.black,
            //           side: BorderSide(
            //             color: isDark ? Colors.white24 : Colors.black26,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      );
    });
  }
}

Widget _benefitRow(String text, bool isDark) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.check_circle,
        size: 18,
        color: isDark ? Colors.greenAccent : Colors.green,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    ],
  );
}

/// 🔹 FOLLOW US ON X
Widget _followOnXButton(bool isDark) {
  const String xUrl = 'https://x.com/Textido?t=Ynwl6eeqlaALeIKjoKYhBg&s=09';

  return GestureDetector(
    onTap: () async {
      final Uri url = Uri.parse(xUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open X',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          colorText: isDark ? Colors.white : Colors.black,
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueAccent.shade700 : Colors.blue.shade600,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          const Text(
            'Follow us on X',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.open_in_new, color: Colors.white, size: 16),
        ],
      ),
    ),
  );
}

// class WalletCard extends StatelessWidget {
//   const WalletCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeCtrl = Get.find<ThemeController>();

//     final balanceCtrl = Get.find<AvailableBalanceController>();

//     final authCtrl = Get.find<AuthController>();

//     final RxBool hideBalance = false.obs;

//     return Obx(() {
//       final isDark = themeCtrl.isDarkMode.value;

//       return AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         padding: const EdgeInsets.all(22),
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xff151515) : Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isDark ? .30 : .06),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Available Balance",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.grey : Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 250),
//               child: Text(
//                 hideBalance.value
//                     ? "••••••"
//                     : "\$${balanceCtrl.avlBal.value.toStringAsFixed(5)}",
//                 key: ValueKey(hideBalance.value),
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Text(
//             //   "Rewards earned from posts, likes, comments and referrals.",
//             //   style: TextStyle(
//             //     fontSize: 12,
//             //     height: 1.5,
//             //     color: isDark ? Colors.grey : Colors.black54,
//             //   ),
//             // ),
//             // const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: Icon(
//                       Icons.account_balance_wallet,
//                       size: 18,
//                       color: isDark ? Colors.black : Colors.white,
//                     ),
//                     label: const Text("Withdraw"),
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       minimumSize: const Size.fromHeight(48),
//                       backgroundColor: isDark ? Colors.white : Colors.black,
//                       foregroundColor: isDark ? Colors.black : Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     onPressed: () async {
//                       final user = authCtrl.currentUser;

//                       if (user == null) return;

//                       final doc = await FirebaseFirestore.instance
//                           .collection('e-users')
//                           .doc(user.uid)
//                           .get();

//                       final verified =
//                           doc.exists && doc.data()?['withdraw_verify'] == true;

//                       if (verified) {
//                         //Get.to(() => WithdrawPage());

//                         return;
//                       }

//                       final ok = await authCtrl.checkWithdrawVerification();

//                       if (ok) {
//                         //Get.to(() => WithdrawPage());

//                         return;
//                       }

//                       await authCtrl.sendWithdrawVerificationEmail();

//                       Get.defaultDialog(
//                         radius: 16,
//                         title: "Withdrawal Locked",
//                         middleText: "Verify your email before withdrawing.\n\nA verification email has been sent to your inbox.",
//                         textConfirm: "OK",
//                         confirmTextColor: Colors.white,
//                         onConfirm: () {
//                           Get.back();
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     icon: Icon(
//                       Icons.history,
//                       size: 18,
//                       color: isDark ? Colors.white : Colors.black,
//                     ),
//                     label: const Text("History"),
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(48),
//                       foregroundColor: isDark ? Colors.white : Colors.black,
//                       side: BorderSide(
//                         color: isDark ? Colors.white24 : Colors.black26,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     // onPressed: () {
//                     //   Get.to(() => const PayHistoryPage());
//                     // },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

class ReferralCard extends StatelessWidget {
  const ReferralCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final ThemeController themeController = Get.find<ThemeController>();

    // final referCtrl = Get.find<ReferController>();
    final ReferController referController = Get.put(ReferController());
    final AuthController authController = Get.find<AuthController>();

    final RxString referCode = ''.obs;
    final RxBool isLoading = true.obs;

    void _showSnackbar(String title, String message) {
      final isDark = themeController.isDarkMode.value;

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        colorText: isDark ? Colors.white : Colors.black,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
    }

    Future<void> loadReferCode() async {
      final uid = authController.currentUser?.uid;

      if (uid == null) {
        isLoading.value = false;
        return;
      }

      try {
        final code = await authController.ensureReferCode(uid);
        referCode.value = code;
      } catch (e) {
        _showSnackbar(
          'Error',
          'Could not load your referral code. Pull to refresh and try again.',
        );
      } finally {
        isLoading.value = false;
      }
    }

    loadReferCode();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff151515) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .30 : .06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Container(
                //   width: 54,
                //   height: 54,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: isDark ? Colors.white12 : Colors.black12,
                //   ),
                //   child: Icon(
                //     Icons.people_alt_outlined,
                //     color: isDark ? Colors.white : Colors.black,
                //   ),
                // ),
                //const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Invite Friends",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 4),

                      // SelectableText(
                      //   "Earn rewards by referring a new user with your referral code: ${referCode.value}",
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     height: 1.5,
                      //     color: isDark ? Colors.grey : Colors.black54,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.share,
                  color: isDark ? Colors.black : Colors.white,
                ),
                label: const Text("Copy Referral Code"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  referController.copyReferralText();
                },
              ),
            ),
            //const SizedBox(height: 12),
            // Center(
            //   child: Text(
            //     "Premium users usually grow faster by inviting quality creators.",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       fontSize: 9,
            //       color: isDark ? Colors.grey : Colors.black54,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}

class DeleteCard extends StatelessWidget {
  const DeleteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final ThemeController themeController = Get.find<ThemeController>();

    // final referCtrl = Get.find<ReferController>();
    //final ReferController referController = Get.put(ReferController());
    final AuthController authController = Get.find<AuthController>();
    final AccountController accountCtrl = Get.find();

    final RxString referCode = ''.obs;
    final RxBool isLoading = true.obs;

    void _showSnackbar(String title, String message) {
      final isDark = themeController.isDarkMode.value;

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        colorText: isDark ? Colors.white : Colors.black,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
    }

    void showDeleteAccountDialog() {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.white, // always white, as requested
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This will permanently delete your account and all associated '
                  'data, including your posts and comments. This action cannot '
                  'be undone.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Get.back(); // close dialog first

                          try {
                            await accountCtrl.deleteAccount();
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Could not delete account. Please try again.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
      );
    }

    Future<void> loadReferCode() async {
      final uid = authController.currentUser?.uid;

      if (uid == null) {
        isLoading.value = false;
        return;
      }

      try {
        final code = await authController.ensureReferCode(uid);
        referCode.value = code;
      } catch (e) {
        _showSnackbar(
          'Error',
          'Could not load your referral code. Pull to refresh and try again.',
        );
      } finally {
        isLoading.value = false;
      }
    }

    loadReferCode();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff151515) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .30 : .06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "Invite Friends",
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: isDark ? Colors.white : Colors.black,
                      //   ),
                      // ),
                      // const SizedBox(height: 4),

                      // SelectableText(
                      //   "Earn rewards by referring a new user with your referral code: ${referCode.value}",
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     height: 1.5,
                      //     color: isDark ? Colors.grey : Colors.black54,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  showDeleteAccountDialog();
                },
              ),
            ),
            // const SizedBox(height: 12),
            // Center(
            //   child: Text(
            //     "Premium users usually grow faster by inviting quality creators.",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       fontSize: 9,
            //       color: isDark ? Colors.grey : Colors.black54,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }
}
