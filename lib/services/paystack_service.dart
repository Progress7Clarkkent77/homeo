// // import 'package:flutter/material.dart';
// // import 'package:flutter_paystack/flutter_paystack.dart';

// // class PaystackMobileService {
// //   static final PaystackPlugin _plugin = PaystackPlugin();
// //   static bool _initialized = false;

// //   /// Call this once (app startup)
// //   static void initialize(String publicKey) {
// //     if (_initialized) return;
// //     _plugin.initialize(publicKey: publicKey);
// //     _initialized = true;
// //   }

// //   /// This is the POPUP you can call anywhere
// //   static Future<bool> chargeCard({
// //     required BuildContext context,
// //     required String email,
// //     required int amountInKobo,
// //     required String reference,
// //   }) async {
// //     final charge = Charge()
// //       ..amount = amountInKobo
// //       ..email = email
// //       ..reference = reference;

// //     try {
// //       final response = await _plugin.checkout(
// //         context,
// //         charge: charge,
// //         method: CheckoutMethod.card,
// //       );

// //       return response.status == true;
// //     } catch (e) {
// //       debugPrint('Paystack error: $e');
// //       return false;
// //     }
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:pay_with_paystack/pay_with_paystack.dart';
// import 'package:homeo/constants/payment_key.dart';

// class PaystackService {
//   static Future<void> startPayment({
//     required BuildContext context,
//     required String email,
//     required String reference,
//     required double amount, // in kobo
//     String currency = "NGN",
//     required Function(Map<String, dynamic>) onSuccess,
//     required Function(String) onError,
//   }) async {
//     try {
//       await PayWithPayStack().now(
//         context: context,
//         secretKey: publicKey, // ✅ mobile uses secretKey for client-side
//         customerEmail: email,
//         reference: reference,
//         currency: currency,
//         amount: amount,
//         callbackUrl: '', // mobile does not require a URL
//         transactionCompleted: (paymentData) {
//           onSuccess(paymentData as Map<String, dynamic>);
//         },
//         transactionNotCompleted: (reason) {
//           onError(reason);
//         },
//       );
//     } catch (e) {
//       onError(e.toString());
//     }
//   }
// }
