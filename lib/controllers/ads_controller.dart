//import 'package:spiiiq/BlockChain/blockchain_controller.dart';
import 'package:homeo/controllers/e_login_controller.dart';
import 'package:homeo/controllers/reward_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class AdsController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController _auth = Get.find<AuthController>();
//   final ThemeController _themeCtrl = Get.find<ThemeController>();
// //  final Blockchain _blockchain = Blockchain();
//   final RewardController _rewardCtrl = Get.find<RewardController>();

//   final RxList<Map<String, dynamic>> ads = <Map<String, dynamic>>[].obs;

//   bool get _isDark => _themeCtrl.isDarkMode.value;
//   String? get uid => _auth.currentUser?.uid;

//   @override
//   void onInit() {
//     super.onInit();
//     _listenToAds();
//     _autoCleanupExpiredAds();
//   }

//   /* -------------------------------------------------------------------------- */
//   /*                               🔹 ADS LIST                                  */
//   /* -------------------------------------------------------------------------- */

//   void _listenToAds() {
//     _firestore
//         .collection('ads')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .listen((snapshot) {
//       ads.assignAll(snapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList());
//     });
//   }

//   /* -------------------------------------------------------------------------- */
//   /*                       🔐 ADD AD (VERIFIED ONLY)                             */
//   /* -------------------------------------------------------------------------- */

//   Future<void> addAd({
//     required String title,
//     required String description,
//     required String avatar,
//   }) async {
//     if (uid == null) return;

//     // 🔹 Validate fields before posting
//     if (title.trim().isEmpty) {
//       _snack('Missing Title', 'Please enter a title for your ad.');
//       return;
//     }
//     if (description.trim().isEmpty) {
//       _snack('Missing Description', 'Please enter a description for your ad.');
//       return;
//     }
//     if (avatar.trim().isEmpty) {
//       _snack('Missing Avatar', 'Please pick an avatar for your ad.');
//       return;
//     }

//     final userRef = _firestore.collection('e-users').doc(uid);
//     final userSnap = await userRef.get();
//     final data = userSnap.data();

//     if (data?['verified'] != true) {
//       _snack('Access denied', 'Only verified users can post ads');
//       return;
//     }

//     final now = DateTime.now();
//     final cycleStart = (data?['adsCycleStartedAt'] as Timestamp?)?.toDate();
//     int posted = data?['adsPostedThisCycle'] ?? 0;

//     if (cycleStart == null || now.difference(cycleStart).inDays >= 30) {
//       posted = 0;
//       await userRef.update({
//         'adsPostedThisCycle': 0,
//         'adsCycleStartedAt': Timestamp.fromDate(now),
//       });
//     }

//     if (posted >= 4) {
//       _snack('Limit reached', 'You can only post 4 ads every 30 days');
//       return;
//     }

//     // 🔹 Add ad
//     await _firestore.collection('ads').add({
//       'uid': uid,
//       'title': title.trim(),
//       'description': description.trim(),
//       'avatar': avatar,
//       'createdAt': FieldValue.serverTimestamp(),
//       'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
//     });

//     await userRef.update({
//       'adsPostedThisCycle': FieldValue.increment(1),
//     });

//     Get.back();
//     _snack('Ad posted', 'Your ad is live');
//   }

//   /* -------------------------------------------------------------------------- */
//   /*                     ⏳ AUTO DELETE EXPIRED ADS                              */
//   /* -------------------------------------------------------------------------- */

//   Future<void> _autoCleanupExpiredAds() async {
//     final now = Timestamp.now();

//     final expired = await _firestore
//         .collection('ads')
//         .where('expiresAt', isLessThan: now)
//         .get();

//     for (final doc in expired.docs) {
//       await doc.reference.delete();
//     }
//   }

//   // /// Reward the user for clicking an ad link (once per ad)
//   // Future<void> handleAdLinkClickReward(String adId) async {
//   //   try {
//   //     final user = _auth.currentUser;
//   //     if (user == null) return;

//   //     final rewardRef = _firestore
//   //         .collection('adRewards') // separate collection for ad link rewards
//   //         .doc(user.uid)
//   //         .collection('clickedAds')
//   //         .doc(adId);

//   //     final rewardSnap = await rewardRef.get();
//   //     if (!rewardSnap.exists) {
//   //       // Fetch user wallet
//   //       final doc = await _firestore.collection('e-users').doc(user.uid).get();
//   //       final wallet = doc.data()?['wallet_address'];
//   //       if (wallet != null) {
//   //         // Call blockchain reward function (replace with your logic)
//   //         await _rewardCtrl.incrementTinyReward();
//   //         await _blockchain.deductAndTransferToken3(wallet);
//   //         print("✅ User rewarded for clicking ad: $wallet");
//   //       }

//   //       // Mark as rewarded
//   //       await rewardRef
//   //           .set({'rewarded': true, 'clickedAt': FieldValue.serverTimestamp()});
//   //     } else {
//   //       print("ℹ️ User already rewarded for this ad: $adId");
//   //     }
//   //   } catch (e) {
//   //     print("❌ Error rewarding user for ad click: $e");
//   //   }
//   // }

//   /// Reward the user for clicking an ad link (once per ad)
//   Future<void> handleAdLinkClickReward(String adId) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final rewardRef = _firestore
//           .collection('adRewards')
//           .doc(user.uid)
//           .collection('clickedAds')
//           .doc(adId);

//       final rewardSnap = await rewardRef.get();
//       if (!rewardSnap.exists) {
//         // ✅ Reward purely by UID
//         await _rewardCtrl.incrementTinyReward(uid: user.uid);
//         print("💰 Rewarded ${user.uid} for clicking ad: $adId");

//         // ✅ Mark as rewarded
//         await rewardRef.set({
//           'rewarded': true,
//           'clickedAt': FieldValue.serverTimestamp(),
//         });
//       } else {
//         print("ℹ️ User already rewarded for this ad: $adId");
//       }
//     } catch (e) {
//       print("❌ Error rewarding user for ad click: $e");
//     }
//   }

//   void _snack(String title, String msg) {
//     Get.snackbar(
//       title,
//       msg,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: _isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//       colorText: _isDark ? Colors.white : Colors.black,
//     );
//   }
// }

class AdsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();
  final ThemeController _themeCtrl = Get.find<ThemeController>();
  //  final Blockchain _blockchain = Blockchain();
  final RewardController _rewardCtrl = Get.find<RewardController>();

  final RxList<Map<String, dynamic>> ads = <Map<String, dynamic>>[].obs;

  bool get _isDark => _themeCtrl.isDarkMode.value;
  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _listenToAds();
    _autoCleanupExpiredAds();
  }

  /* -------------------------------------------------------------------------- */
  /*                               🔹 ADS LIST                                  */
  /* -------------------------------------------------------------------------- */

  void _listenToAds() {
    _firestore
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
          ads.assignAll(
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList(),
          );
        });
  }

  /* -------------------------------------------------------------------------- */
  /*                       🔐 ADD AD (VERIFIED ONLY)                             */
  /* -------------------------------------------------------------------------- */

  /// 🔹 Post an ad — text only (title + description), no avatar.
  /// No verification gate and no per-user/day posting limit: any signed-in
  /// user can post as many ads as they like.
  Future<void> addAd({
    required String title,
    required String description,
  }) async {
    if (uid == null) return;

    // 🔹 Validate fields before posting
    if (title.trim().isEmpty) {
      _snack('Missing Title', 'Please enter a title for your ad.');
      return;
    }
    if (description.trim().isEmpty) {
      _snack('Missing Description', 'Please enter a description for your ad.');
      return;
    }

    final now = DateTime.now();

    // 🔹 Add ad
    await _firestore.collection('ads').add({
      'uid': uid,
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
    });

    Get.back();
    _snack('Ad posted', 'Your ad is live');
  }

  /* -------------------------------------------------------------------------- */
  /*                   📢 SPONSORED SLOTS FOR THE MAIN FEED                     */
  /* -------------------------------------------------------------------------- */

  /// 🔹 Returns the ad to show at a given sponsored "slot" in a feed — one
  /// slot is requested after every 5 normal posts. Cycles through the live
  /// `ads` list so slots keep rotating through every ad as more are posted.
  /// Returns null when there are no ads to show yet.
  Map<String, dynamic>? adForSlot(int slot) {
    if (ads.isEmpty) return null;
    return ads[slot % ads.length];
  }

  /* -------------------------------------------------------------------------- */
  /*                     ⏳ AUTO DELETE EXPIRED ADS                              */
  /* -------------------------------------------------------------------------- */

  Future<void> _autoCleanupExpiredAds() async {
    final now = Timestamp.now();

    final expired = await _firestore
        .collection('ads')
        .where('expiresAt', isLessThan: now)
        .get();

    for (final doc in expired.docs) {
      await doc.reference.delete();
    }
  }

  // /// Reward the user for clicking an ad link (once per ad)
  // Future<void> handleAdLinkClickReward(String adId) async {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) return;

  //     final rewardRef = _firestore
  //         .collection('adRewards') // separate collection for ad link rewards
  //         .doc(user.uid)
  //         .collection('clickedAds')
  //         .doc(adId);

  //     final rewardSnap = await rewardRef.get();
  //     if (!rewardSnap.exists) {
  //       // Fetch user wallet
  //       final doc = await _firestore.collection('e-users').doc(user.uid).get();
  //       final wallet = doc.data()?['wallet_address'];
  //       if (wallet != null) {
  //         // Call blockchain reward function (replace with your logic)
  //         await _rewardCtrl.incrementTinyReward();
  //         await _blockchain.deductAndTransferToken3(wallet);
  //         print("✅ User rewarded for clicking ad: $wallet");
  //       }

  //       // Mark as rewarded
  //       await rewardRef
  //           .set({'rewarded': true, 'clickedAt': FieldValue.serverTimestamp()});
  //     } else {
  //       print("ℹ️ User already rewarded for this ad: $adId");
  //     }
  //   } catch (e) {
  //     print("❌ Error rewarding user for ad click: $e");
  //   }
  // }

  /// Reward the user for clicking an ad link (once per ad)
  Future<void> handleAdLinkClickReward(String adId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final rewardRef = _firestore
          .collection('adRewards')
          .doc(user.uid)
          .collection('clickedAds')
          .doc(adId);

      final rewardSnap = await rewardRef.get();
      if (!rewardSnap.exists) {
        // ✅ Reward purely by UID
        await _rewardCtrl.incrementTinyReward(uid: user.uid);
        print("💰 Rewarded ${user.uid} for clicking ad: $adId");

        // ✅ Mark as rewarded
        await rewardRef.set({
          'rewarded': true,
          'clickedAt': FieldValue.serverTimestamp(),
        });
      } else {
        print("ℹ️ User already rewarded for this ad: $adId");
      }
    } catch (e) {
      print("❌ Error rewarding user for ad click: $e");
    }
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      colorText: _isDark ? Colors.white : Colors.black,
    );
  }
}
