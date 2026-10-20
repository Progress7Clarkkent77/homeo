import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// class rController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController authController = Get.find<AuthController>();

//   /// Increment user's available balance by 0.0001
//   Future<void> incrementTinyr() async {
//     await _incrementBalance(0.00005);
//   }

//   /// Increment user's available balance by 0.007
//   Future<void> incrementSmallr() async {
//     await _incrementBalance(0.002);
//   }

//   /// Increment user's available balance by 0.005
//   Future<void> incrementMediumr() async {
//     await _incrementBalance(0.005);
//   }

//   Future<void> incrementRefer() async {
//     await _incrementBalance(0.003);
//   }

//   Future<void> incrementChatr() async {
//     await _incrementBalance(0.00005);
//   }

//   /// Generic function to increment user's balance safely
//   Future<void> _incrementBalance(double amount) async {
//     final uid = authController.currentUser?.uid;
//     if (uid == null) return;

//     try {
//       final userRef = _firestore.collection('e-users').doc(uid);
//       final userSnap = await userRef.get();

//       double currentBal = 0.0;
//       if (userSnap.exists) {
//         final data = userSnap.data();
//         final rawBal = data?['available_bal'];
//         if (rawBal is num) currentBal = rawBal.toDouble();
//       }

//       // Update Firestore with new balance
//       await userRef.update({'available_bal': currentBal + amount});
//       print(
//           "Balance incremented by $amount. New balance: ${currentBal + amount}");
//     } catch (e, stack) {
//       print("rController Exception: $e");
//       print("StackTrace: $stack");
//     }
//   }
// }

class RController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Tiny r (0.00005)
  Future<void> incrementTinyr({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00010);
  }

  Future<void> incrementMarketr({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0008);
  }

  Future<void> incrementCommentr({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.0002);
  }

  /// 🔹 Small r (0.002)
  Future<void> incrementSmallr({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.002);
  }

  /// 🔹 Medium r (0.005)
  Future<void> incrementMediumr({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.005);
  }

  /// 🔹 Referral r (0.003)
  Future<void> incrementRefer({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.009);
  }

  /// 🔹 Chat r (0.00005)
  Future<void> incrementChatr({required String uid}) async {
    await _incrementBalance(uid: uid, amount: 0.00005);
  }

  /// 🔥 Core atomic increment function
  Future<void> _incrementBalance({
    required String uid,
    required double amount,
  }) async {
    try {
      final userRef = _firestore.collection('e-users').doc(uid);

      await userRef.update({'available_bal': FieldValue.increment(amount)});

      print("💰 red $uid with $amount");
    } catch (e, stack) {
      print("❌ rController Exception: $e");
      print("StackTrace: $stack");
    }
  }
}
