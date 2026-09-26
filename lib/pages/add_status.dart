// import 'package:spiiiq/controllers/account_controller.dart';

// import 'package:spiiiq/controllers/chat_list_controller.dart';
// import 'package:spiiiq/controllers/status_controller.dart';
// import 'package:spiiiq/controllers/theme_controller.dart';
// import 'package:spiiiq/controllers/verified_controller.dart';
// import 'package:spiiiq/pages/home.dart';
// import 'package:spiiiq/pages/status_screen.dart';
// import 'package:spiiiq/widgets/url_launcher.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// // class AddStatus extends StatefulWidget {
// //   final String userName;
// //   final String userEmail;

// //   const AddStatus({
// //     super.key,
// //     required this.userName,
// //     required this.userEmail,
// //   });

// //   @override
// //   State<AddStatus> createState() => _AddStatusState();
// // }

// // class _AddStatusState extends State<AddStatus> {
// //   final ChatListController controller = Get.put(ChatListController());

// //   final ThemeController themeCtrl = Get.put(ThemeController());

// //   final AccountController accountController = Get.put(AccountController());
// //   final IconNavigationHandler navigationHandler = IconNavigationHandler();
// //   // final CurrencyController currencyController = Get.put(CurrencyController());
// //   // final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
// //   // final PbcMarketController pbcMarketController =
// //   //     Get.put(PbcMarketController());

// //   /// 🔹 Obfuscate email
// //   String obfuscateEmail(String email) {
// //     final parts = email.split('@');
// //     if (parts.isEmpty) return email;

// //     final name = parts[0];
// //     final domain = parts.length > 1 ? '@${parts[1]}' : '';

// //     if (name.length <= 4) {
// //       // If too short, just show first letter + dots + last letter
// //       final first = name.substring(0, 1);
// //       final last = name.length > 1 ? name.substring(name.length - 1) : '';
// //       return '$first....$last$domain';
// //     }

// //     final firstTwo = name.substring(0, 2);
// //     final lastTwo = name.substring(name.length - 2);
// //     return '$firstTwo....$lastTwo$domain';
// //   }

// //   @override
// //   void initState() {
// //     super.initState();

// //     accountController.fetchUserInfo();
// //     //accountController.fetchBalances(); // Fetch data on widget load
// //     accountController.fetchWalletAddress(); // Fetch wallet address on init
// //     accountController.toggleBalanceVisibility();
// //     accountController.fetchWalletDetails();
// //     accountController
// //         .fetchWalletAddress(); // Fetch wallet address on initialization
// //     accountController
// //         .fetchWalletData(); // Fetch both address & publicKey on init
// //     // addMoneyController.fetchVaultBalance();

// //     // Watch for email availability and fetch transactions once it's ready
// //     // ever(addMoneyController.email, (String email) {
// //     //   if (email.isNotEmpty) {
// //     //     addMoneyController.fetchTransactions(email);
// //     //   }
// //     // });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final ThemeController themeCtrl = Get.find<ThemeController>();
// //     final StatusController statusCtrl = Get.put(StatusController());
// //     final TextEditingController inputCtrl = TextEditingController();

// //     final userInitial =
// //         widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?';

// //     return Obx(() {
// //       final isDark = themeCtrl.isDarkMode.value;
// //       return Scaffold(
// //           backgroundColor: isDark ? Colors.black : Colors.white,
// //           appBar: AppBar(
// //             backgroundColor: isDark ? Colors.black : Colors.white,
// //             elevation: 0,
// //             iconTheme:
// //                 IconThemeData(color: isDark ? Colors.white : Colors.black),
// //             title: Text(
// //               'Post Updates',
// //               style: TextStyle(
// //                 color: isDark ? Colors.white : Colors.black,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //           body: Column(
// //             children: [
// //               /// ✍️ STATUS COMPOSER
// //               const SizedBox(height: 10),

// //               Divider(
// //                 height: 1,
// //                 thickness: 0.6,
// //                 color: isDark ? Colors.white24 : Colors.black12,
// //               ),
// //               const SizedBox(height: 8),
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 child: Container(
// //                     padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
// //                     decoration: BoxDecoration(
// //                       color:
// //                           isDark ? Colors.grey.shade900 : Colors.grey.shade100,
// //                       borderRadius: BorderRadius.circular(16),
// //                     ),

// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         /// ===========================
// //                         /// USER HEADER
// //                         /// ===========================
// //                         Row(
// //                           children: [
// //                             CircleAvatar(
// //                               radius: 22,
// //                               backgroundColor: Colors.white,
// //                               backgroundImage:
// //                                   accountController.avatarName.value.isNotEmpty
// //                                       ? AssetImage(
// //                                           'assets/images/${accountController.avatarName.value}.png',
// //                                         )
// //                                       : null,
// //                               child: accountController.avatarName.value.isEmpty
// //                                   ? Text(
// //                                       userInitial,
// //                                       style: const TextStyle(
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Colors.black,
// //                                       ),
// //                                     )
// //                                   : null,
// //                             ),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Row(
// //                                     children: [
// //                                       Flexible(
// //                                         child: Text(
// //                                           widget.userName,
// //                                           overflow: TextOverflow.ellipsis,
// //                                           style: TextStyle(
// //                                             fontSize: 15,
// //                                             fontWeight: FontWeight.w700,
// //                                             color: isDark
// //                                                 ? Colors.white
// //                                                 : Colors.black,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                       const SizedBox(width: 4),
// //                                       if (Get.find<VerifiedController>()
// //                                           .isVerified
// //                                           .value)
// //                                         Image.asset(
// //                                           "assets/images/verified.png",
// //                                           width: 15,
// //                                           height: 15,
// //                                         ),
// //                                     ],
// //                                   ),
// //                                   const SizedBox(height: 2),
// //                                   Text(
// //                                     obfuscateEmail(widget.userEmail),
// //                                     style: TextStyle(
// //                                       fontSize: 12,
// //                                       color:
// //                                           isDark ? Colors.grey : Colors.black54,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),

// //                         const SizedBox(height: 20),

// //                         /// ===========================
// //                         /// COMPOSER
// //                         /// ===========================
// //                         Container(
// //                           decoration: BoxDecoration(
// //                             color: isDark
// //                                 ? Colors.grey.shade900.withOpacity(.45)
// //                                 : Colors.grey.shade50,
// //                             borderRadius: BorderRadius.circular(18),
// //                             border: Border.all(
// //                               color: isDark ? Colors.white10 : Colors.black12,
// //                             ),
// //                           ),
// //                           child: TextField(
// //                             controller: inputCtrl,
// //                             minLines: 1,
// //                             maxLines: 1,
// //                             maxLength: 40,
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               height: 1.45,
// //                               color: isDark ? Colors.white : Colors.black,
// //                             ),
// //                             decoration: InputDecoration(
// //                               counterText: "",
// //                               border: InputBorder.none,
// //                               contentPadding: const EdgeInsets.fromLTRB(
// //                                 18,
// //                                 18,
// //                                 18,
// //                                 18,
// //                               ),
// //                               hintText: "Share something with everyone...",
// //                               hintStyle: TextStyle(
// //                                 fontSize: 14,
// //                                 color: isDark ? Colors.white38 : Colors.black38,
// //                               ),
// //                             ),
// //                           ),
// //                         ),

// //                         const SizedBox(height: 10),

// //                         /// ===========================
// //                         /// IMAGE PREVIEW
// //                         /// ===========================
// //                         Obx(() {
// //                           final image = statusCtrl.selectedImageBytes.value;

// //                           if (image == null) {
// //                             return const SizedBox.shrink();
// //                           }

// //                           return Stack(
// //                             children: [
// //                               ClipRRect(
// //                                 borderRadius: BorderRadius.circular(18),
// //                                 child: Image.memory(
// //                                   image,
// //                                   height: 180,
// //                                   width: double.infinity,
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                               ),
// //                               Positioned(
// //                                 top: 10,
// //                                 right: 10,
// //                                 child: GestureDetector(
// //                                   onTap: () {
// //                                     statusCtrl.selectedImageBytes.value = null;
// //                                   },
// //                                   child: Container(
// //                                     padding: const EdgeInsets.all(6),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.black54,
// //                                       shape: BoxShape.circle,
// //                                     ),
// //                                     child: const Icon(
// //                                       Icons.close,
// //                                       color: Colors.white,
// //                                       size: 18,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           );
// //                         }),

// //                         const SizedBox(height: 16),

// //                         /// VOICE UI GOES HERE
// //                         Obx(() {
// //                           /// Nothing selected
// //                           if (!statusCtrl.isRecording.value &&
// //                               !statusCtrl.hasRecordedAudio.value) {
// //                             return const SizedBox.shrink();
// //                           }

// //                           return AnimatedContainer(
// //                             duration: const Duration(milliseconds: 250),
// //                             margin: const EdgeInsets.only(bottom: 18),
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: isDark
// //                                   ? Colors.grey.shade900
// //                                   : Colors.grey.shade50,
// //                               borderRadius: BorderRadius.circular(18),
// //                               border: Border.all(
// //                                 color: statusCtrl.isRecording.value
// //                                     ? Colors.redAccent.withOpacity(.35)
// //                                     : (isDark
// //                                         ? Colors.white10
// //                                         : Colors.black12),
// //                               ),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: isDark
// //                                       ? Colors.black26
// //                                       : Colors.black.withOpacity(.05),
// //                                   blurRadius: 16,
// //                                   offset: const Offset(0, 8),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Row(
// //                                   children: [
// //                                     AnimatedContainer(
// //                                       duration:
// //                                           const Duration(milliseconds: 600),
// //                                       width: 10,
// //                                       height: 10,
// //                                       decoration: BoxDecoration(
// //                                         color: statusCtrl.isRecording.value
// //                                             ? Colors.red
// //                                             : Colors.green,
// //                                         shape: BoxShape.circle,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(width: 10),
// //                                     Text(
// //                                       statusCtrl.isRecording.value
// //                                           ? "Recording Voice..."
// //                                           : "Voice Ready",
// //                                       style: TextStyle(
// //                                         fontWeight: FontWeight.w700,
// //                                         fontSize: 14,
// //                                         color: isDark
// //                                             ? Colors.white
// //                                             : Colors.black,
// //                                       ),
// //                                     ),
// //                                     const Spacer(),
// //                                     if (statusCtrl.hasRecordedAudio.value)
// //                                       GestureDetector(
// //                                         onTap: statusCtrl.removeRecordedVoice,
// //                                         child: Container(
// //                                           padding: const EdgeInsets.all(7),
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.red.withOpacity(.08),
// //                                             shape: BoxShape.circle,
// //                                           ),
// //                                           child: const Icon(
// //                                             Icons.delete_outline,
// //                                             color: Colors.red,
// //                                             size: 18,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                   ],
// //                                 ),
// //                                 const SizedBox(height: 18),
// //                                 Row(
// //                                   children: List.generate(
// //                                     28,
// //                                     (index) {
// //                                       final height = (index % 6 + 1) * 6.0;

// //                                       return Expanded(
// //                                         child: Padding(
// //                                           padding: const EdgeInsets.symmetric(
// //                                               horizontal: 1),
// //                                           child: AnimatedContainer(
// //                                             duration: Duration(
// //                                               milliseconds: 120 + (index * 15),
// //                                             ),
// //                                             height: statusCtrl.isRecording.value
// //                                                 ? height
// //                                                 : 10,
// //                                             decoration: BoxDecoration(
// //                                               color:
// //                                                   statusCtrl.isRecording.value
// //                                                       ? Colors.red
// //                                                       : Colors.grey,
// //                                               borderRadius:
// //                                                   BorderRadius.circular(100),
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       );
// //                                     },
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 18),
// //                                 Row(
// //                                   children: [
// //                                     Icon(
// //                                       statusCtrl.isRecording.value
// //                                           ? Icons.mic
// //                                           : Icons.play_arrow_rounded,
// //                                       size: 18,
// //                                       color: isDark
// //                                           ? Colors.white70
// //                                           : Colors.black54,
// //                                     ),
// //                                     const SizedBox(width: 8),
// //                                     Obx(() {
// //                                       return Text(
// //                                         "${statusCtrl.recordDuration.value}s / 30s",
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.w600,
// //                                           fontSize: 13,
// //                                           color: isDark
// //                                               ? Colors.white70
// //                                               : Colors.black54,
// //                                         ),
// //                                       );
// //                                     }),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           );
// //                         }),

// //                         /// TOOLBAR GOES HERE
// //                         Row(
// //                           children: [
// //                             /// ===============================
// //                             /// IMAGE BUTTON
// //                             /// ===============================
// //                             Expanded(
// //                               child: InkWell(
// //                                 borderRadius: BorderRadius.circular(14),
// //                                 onTap: () {
// //                                   statusCtrl.pickImageFromDevice();
// //                                 },
// //                                 child: Container(
// //                                   height: 48,
// //                                   decoration: BoxDecoration(
// //                                     color: isDark
// //                                         ? Colors.grey.shade900
// //                                         : Colors.grey.shade100,
// //                                     borderRadius: BorderRadius.circular(14),
// //                                     border: Border.all(
// //                                       color: isDark
// //                                           ? Colors.white10
// //                                           : Colors.black12,
// //                                     ),
// //                                   ),
// //                                   child: Row(
// //                                     mainAxisAlignment: MainAxisAlignment.center,
// //                                     children: [
// //                                       Icon(
// //                                         Icons.image_outlined,
// //                                         size: 20,
// //                                         color: isDark
// //                                             ? Colors.white
// //                                             : Colors.black,
// //                                       ),
// //                                       const SizedBox(width: 8),
// //                                       Text(
// //                                         "Image",
// //                                         style: TextStyle(
// //                                           fontWeight: FontWeight.w600,
// //                                           color: isDark
// //                                               ? Colors.white
// //                                               : Colors.black,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),

// //                             const SizedBox(width: 12),

// //                             /// ===============================
// //                             /// VOICE BUTTON
// //                             /// ===============================
// //                             Expanded(
// //                               child: InkWell(
// //                                 borderRadius: BorderRadius.circular(14),
// //                                 onTap: () {
// //                                   if (statusCtrl.isRecording.value) {
// //                                     statusCtrl.stopVoiceRecording();
// //                                   } else {
// //                                     statusCtrl.startVoiceRecording();
// //                                   }
// //                                 },
// //                                 child: Obx(() {
// //                                   return AnimatedContainer(
// //                                     duration: const Duration(milliseconds: 250),
// //                                     height: 48,
// //                                     decoration: BoxDecoration(
// //                                       color: statusCtrl.isRecording.value
// //                                           ? Colors.red
// //                                           : (isDark
// //                                               ? Colors.grey.shade900
// //                                               : Colors.grey.shade100),
// //                                       borderRadius: BorderRadius.circular(14),
// //                                       border: Border.all(
// //                                         color: statusCtrl.isRecording.value
// //                                             ? Colors.red
// //                                             : (isDark
// //                                                 ? Colors.white10
// //                                                 : Colors.black12),
// //                                       ),
// //                                     ),
// //                                     child: Row(
// //                                       mainAxisAlignment:
// //                                           MainAxisAlignment.center,
// //                                       children: [
// //                                         Icon(
// //                                           statusCtrl.isRecording.value
// //                                               ? Icons.stop_circle
// //                                               : Icons.mic_none,
// //                                           color: isDark
// //                                               ? Colors.white
// //                                               : Colors.black,
// //                                           size: 20,
// //                                         ),
// //                                         const SizedBox(width: 8),
// //                                         Text(
// //                                           statusCtrl.isRecording.value
// //                                               ? "Stop"
// //                                               : "Voice",
// //                                           style: TextStyle(
// //                                             color: isDark
// //                                                 ? Colors.white
// //                                                 : Colors.black,
// //                                             fontWeight: FontWeight.w600,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   );
// //                                 }),
// //                               ),
// //                             ),

// //                             const SizedBox(width: 14),

// //                             /// ===============================
// //                             /// SEND BUTTON
// //                             /// ===============================
// //                             GestureDetector(
// //                               onTap: () {
// //                                 final text = inputCtrl.text.trim();

// //                                 statusCtrl.postStatus(
// //                                   text,
// //                                   widget.userName,
// //                                   widget.userEmail,
// //                                 );

// //                                 inputCtrl.clear();

// //                                 Get.to(
// //                                   () => StatusScreen(
// //                                     userName: accountController.userName.value,
// //                                     userEmail:
// //                                         accountController.userEmail.value,
// //                                   ),
// //                                 );
// //                               },
// //                               child: Container(
// //                                 width: 56,
// //                                 height: 56,
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.black,
// //                                   shape: BoxShape.circle,
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.black.withOpacity(.25),
// //                                       blurRadius: 15,
// //                                       offset: const Offset(0, 8),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: const Icon(
// //                                   Icons.arrow_upward_rounded,
// //                                   color: Colors.white,
// //                                   size: 26,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     )),
// //               ),
// //             ],
// //           ));
// //     });
// //   }
// // }

// // Make sure these are imported in your project:
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'status_controller.dart';
// // import 'status_screen.dart'; // for StatusScreen
// // plus your ThemeController, AccountController, VerifiedController, etc.

// class AddStatus extends StatefulWidget {
//   final String userName;
//   final String userEmail;

//   const AddStatus({super.key, required this.userName, required this.userEmail});

//   @override
//   State<AddStatus> createState() => _AddStatusState();
// }

// class _AddStatusState extends State<AddStatus> {
//   final ChatListController controller = Get.put(ChatListController());
//   final ThemeController themeCtrl = Get.put(ThemeController());
//   final AccountController accountController = Get.put(AccountController());
//   final IconNavigationHandler navigationHandler = IconNavigationHandler();

//   // 🔧 FIX: put controllers once in initState, not on every build().
//   // Get.put(SomeController()) inside build() is called on *every* rebuild
//   // (every Obx tick), which is wasteful and can re-trigger constructor
//   // side effects depending on your controller. Get.find is the correct
//   // call inside build() once the controller has already been put.
//   late final StatusController statusCtrl;

//   final TextEditingController inputCtrl = TextEditingController();

//   /// 🔹 Obfuscate email
//   String obfuscateEmail(String email) {
//     final parts = email.split('@');
//     if (parts.isEmpty) return email;

//     final name = parts[0];
//     final domain = parts.length > 1 ? '@${parts[1]}' : '';

//     if (name.length <= 4) {
//       final first = name.substring(0, 1);
//       final last = name.length > 1 ? name.substring(name.length - 1) : '';
//       return '$first....$last$domain';
//     }

//     final firstTwo = name.substring(0, 2);
//     final lastTwo = name.substring(name.length - 2);
//     return '$firstTwo....$lastTwo$domain';
//   }

//   @override
//   void initState() {
//     super.initState();

//     statusCtrl = Get.put(StatusController());

//     accountController.fetchUserInfo();
//     accountController.fetchWalletAddress();
//     accountController.toggleBalanceVisibility();
//     accountController.fetchWalletDetails();
//     accountController.fetchWalletData();
//   }

//   @override
//   void dispose() {
//     inputCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userInitial = widget.userName.isNotEmpty
//         ? widget.userName[0].toUpperCase()
//         : '?';

//     return Obx(() {
//       final isDark = themeCtrl.isDarkMode.value;
//       return Scaffold(
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         appBar: AppBar(
//           backgroundColor: isDark ? Colors.black : Colors.white,
//           elevation: 0,
//           iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
//           title: Text(
//             'Post Updates',
//             style: TextStyle(
//               color: isDark ? Colors.white : Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             const SizedBox(height: 10),
//             Divider(
//               height: 1,
//               thickness: 0.6,
//               color: isDark ? Colors.white24 : Colors.black12,
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// USER HEADER
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 22,
//                           backgroundColor: Colors.white,
//                           backgroundImage:
//                               accountController.avatarName.value.isNotEmpty
//                               ? AssetImage(
//                                   'assets/images/${accountController.avatarName.value}.png',
//                                 )
//                               : null,
//                           child: accountController.avatarName.value.isEmpty
//                               ? Text(
//                                   userInitial,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 )
//                               : null,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Flexible(
//                                     child: Text(
//                                       widget.userName,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w700,
//                                         color: isDark
//                                             ? Colors.white
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   if (Get.find<VerifiedController>()
//                                       .isVerified
//                                       .value)
//                                     Image.asset(
//                                       "assets/images/verified.png",
//                                       width: 15,
//                                       height: 15,
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 obfuscateEmail(widget.userEmail),
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: isDark ? Colors.grey : Colors.black54,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 20),

//                     /// COMPOSER
//                     Container(
//                       decoration: BoxDecoration(
//                         color: isDark
//                             ? Colors.grey.shade900.withOpacity(.45)
//                             : Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(18),
//                         border: Border.all(
//                           color: isDark ? Colors.white10 : Colors.black12,
//                         ),
//                       ),
//                       child: TextField(
//                         controller: inputCtrl,
//                         minLines: 1,
//                         maxLines: 1,
//                         maxLength: 40,
//                         style: TextStyle(
//                           fontSize: 15,
//                           height: 1.45,
//                           color: isDark ? Colors.white : Colors.black,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.fromLTRB(
//                             18,
//                             18,
//                             18,
//                             18,
//                           ),
//                           hintText: "Share something with everyone...",
//                           hintStyle: TextStyle(
//                             fontSize: 14,
//                             color: isDark ? Colors.white38 : Colors.black38,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     /// IMAGE PREVIEW
//                     Obx(() {
//                       final image = statusCtrl.selectedImageBytes.value;

//                       if (image == null) {
//                         return const SizedBox.shrink();
//                       }

//                       return Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(18),
//                             child: Image.memory(
//                               image,
//                               height: 180,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned(
//                             top: 10,
//                             right: 10,
//                             child: GestureDetector(
//                               onTap: () {
//                                 statusCtrl.selectedImageBytes.value = null;
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.close,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       );
//                     }),

//                     const SizedBox(height: 16),

//                     /// VOICE UI
//                     Obx(() {
//                       if (!statusCtrl.isRecording.value &&
//                           !statusCtrl.hasRecordedAudio.value) {
//                         return const SizedBox.shrink();
//                       }

//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 250),
//                         margin: const EdgeInsets.only(bottom: 18),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? Colors.grey.shade900
//                               : Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(18),
//                           border: Border.all(
//                             color: statusCtrl.isRecording.value
//                                 ? Colors.redAccent.withOpacity(.35)
//                                 : (isDark ? Colors.white10 : Colors.black12),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: isDark
//                                   ? Colors.black26
//                                   : Colors.black.withOpacity(.05),
//                               blurRadius: 16,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 600),
//                                   width: 10,
//                                   height: 10,
//                                   decoration: BoxDecoration(
//                                     color: statusCtrl.isRecording.value
//                                         ? Colors.red
//                                         : Colors.green,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   statusCtrl.isRecording.value
//                                       ? "Recording Voice..."
//                                       : "Voice Ready",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14,
//                                     color: isDark ? Colors.white : Colors.black,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 if (statusCtrl.hasRecordedAudio.value)
//                                   GestureDetector(
//                                     onTap: statusCtrl.removeRecordedVoice,
//                                     child: Container(
//                                       padding: const EdgeInsets.all(7),
//                                       decoration: BoxDecoration(
//                                         color: Colors.red.withOpacity(.08),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(
//                                         Icons.delete_outline,
//                                         color: Colors.red,
//                                         size: 18,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             const SizedBox(height: 18),
//                             Row(
//                               children: List.generate(28, (index) {
//                                 final height = (index % 6 + 1) * 6.0;

//                                 return Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 1,
//                                     ),
//                                     child: AnimatedContainer(
//                                       duration: Duration(
//                                         milliseconds: 120 + (index * 15),
//                                       ),
//                                       height: statusCtrl.isRecording.value
//                                           ? height
//                                           : 10,
//                                       decoration: BoxDecoration(
//                                         color: statusCtrl.isRecording.value
//                                             ? Colors.red
//                                             : Colors.grey,
//                                         borderRadius: BorderRadius.circular(
//                                           100,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(height: 18),
//                             Row(
//                               children: [
//                                 Icon(
//                                   statusCtrl.isRecording.value
//                                       ? Icons.mic
//                                       : Icons.play_arrow_rounded,
//                                   size: 18,
//                                   color: isDark
//                                       ? Colors.white70
//                                       : Colors.black54,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Obx(() {
//                                   return Text(
//                                     "${statusCtrl.recordDuration.value}s / 30s",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                       color: isDark
//                                           ? Colors.white70
//                                           : Colors.black54,
//                                     ),
//                                   );
//                                 }),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     }),

//                     /// TOOLBAR
//                     Row(
//                       children: [
//                         /// IMAGE BUTTON
//                         Expanded(
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(14),
//                             onTap: () {
//                               statusCtrl.pickImageFromDevice();
//                             },
//                             child: Container(
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: isDark
//                                     ? Colors.grey.shade900
//                                     : Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(14),
//                                 border: Border.all(
//                                   color: isDark
//                                       ? Colors.white10
//                                       : Colors.black12,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.image_outlined,
//                                     size: 20,
//                                     color: isDark ? Colors.white : Colors.black,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     "Image",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       color: isDark
//                                           ? Colors.white
//                                           : Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         /// VOICE BUTTON
//                         Expanded(
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(14),
//                             onTap: () {
//                               if (statusCtrl.isRecording.value) {
//                                 statusCtrl.stopVoiceRecording();
//                               } else {
//                                 statusCtrl.startVoiceRecording();
//                               }
//                             },
//                             child: Obx(() {
//                               return AnimatedContainer(
//                                 duration: const Duration(milliseconds: 250),
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   color: statusCtrl.isRecording.value
//                                       ? Colors.red
//                                       : (isDark
//                                             ? Colors.grey.shade900
//                                             : Colors.grey.shade100),
//                                   borderRadius: BorderRadius.circular(14),
//                                   border: Border.all(
//                                     color: statusCtrl.isRecording.value
//                                         ? Colors.red
//                                         : (isDark
//                                               ? Colors.white10
//                                               : Colors.black12),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       statusCtrl.isRecording.value
//                                           ? Icons.stop_circle
//                                           : Icons.mic_none,
//                                       color: isDark
//                                           ? Colors.white
//                                           : Colors.black,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       statusCtrl.isRecording.value
//                                           ? "Stop"
//                                           : "Voice",
//                                       style: TextStyle(
//                                         color: isDark
//                                             ? Colors.white
//                                             : Colors.black,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ),
//                         ),

//                         const SizedBox(width: 14),

//                         /// SEND BUTTON
//                         // GestureDetector(
//                         //   onTap: () async {
//                         //     final text = inputCtrl.text.trim();

//                         //     // 🔧 Wait for the post to actually finish
//                         //     // (uploading image/voice + Firestore write)
//                         //     // before navigating away, otherwise you can
//                         //     // navigate mid-upload and lose the post.
//                         //     await statusCtrl.postStatus(
//                         //       text,
//                         //       widget.userName,
//                         //       widget.userEmail,
//                         //     );

//                         //     inputCtrl.clear();

//                         //     Get.to(
//                         //       () => StatusScreen(
//                         //         userName: accountController.userName.value,
//                         //         userEmail:
//                         //             accountController.userEmail.value,
//                         //       ),
//                         //     );
//                         //   },
//                         //   child: Container(
//                         //     width: 56,
//                         //     height: 56,
//                         //     decoration: BoxDecoration(
//                         //       color: Colors.black,
//                         //       shape: BoxShape.circle,
//                         //       boxShadow: [
//                         //         BoxShadow(
//                         //           color: Colors.black.withOpacity(.25),
//                         //           blurRadius: 15,
//                         //           offset: const Offset(0, 8),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //     child: const Icon(
//                         //       Icons.arrow_upward_rounded,
//                         //       color: Colors.white,
//                         //       size: 26,
//                         //     ),
//                         //   ),
//                         // ),
//                         Obx(() {
//                           final isPosting = statusCtrl.isPosting.value;

//                           return GestureDetector(
//                             onTap: isPosting
//                                 ? null
//                                 : () async {
//                                     final text = inputCtrl.text.trim();

//                                     await statusCtrl.postStatus(
//                                       text,
//                                       widget.userName,
//                                       widget.userEmail,
//                                     );

//                                     if (!mounted) return;

//                                     inputCtrl.clear();

//                                     Get.to(
//                                       () => Home(
//                                         userName:
//                                             accountController.userName.value,
//                                         userEmail:
//                                             accountController.userEmail.value,
//                                       ),
//                                     );
//                                   },
//                             child: Container(
//                               width: 56,
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isPosting
//                                     ? Colors.black45
//                                     : Colors.black,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(.25),
//                                     blurRadius: 15,
//                                     offset: const Offset(0, 8),
//                                   ),
//                                 ],
//                               ),
//                               child: isPosting
//                                   ? const Padding(
//                                       padding: EdgeInsets.all(16),
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2.5,
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                   : const Icon(
//                                       Icons.arrow_upward_rounded,
//                                       color: Colors.white,
//                                       size: 26,
//                                     ),
//                             ),
//                           );
//                         }),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

import 'package:homeo/controllers/account_controller.dart';

//import 'package:homeo/controllers/chat_list_controller.dart';
import 'package:homeo/controllers/status_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/controllers/verified_controller.dart';
import 'package:homeo/pages/home.dart';
import 'package:homeo/widgets/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddStatus extends StatefulWidget {
  final String userName;
  final String userEmail;

  const AddStatus({super.key, required this.userName, required this.userEmail});

  @override
  State<AddStatus> createState() => _AddStatusState();
}

class _AddStatusState extends State<AddStatus> {
  //final ChatListController controller = Get.put(ChatListController());
  final ThemeController themeCtrl = Get.put(ThemeController());
  final AccountController accountController = Get.put(AccountController());
  final IconNavigationHandler navigationHandler = IconNavigationHandler();

  // 🔧 FIX: put controllers once in initState, not on every build().
  // Get.put(SomeController()) inside build() is called on *every* rebuild
  // (every Obx tick), which is wasteful and can re-trigger constructor
  // side effects depending on your controller. Get.find is the correct
  // call inside build() once the controller has already been put.
  late final StatusController statusCtrl;

  final TextEditingController inputCtrl = TextEditingController();

  /// 🔹 Obfuscate email
  String obfuscateEmail(String email) {
    final parts = email.split('@');
    if (parts.isEmpty) return email;

    final name = parts[0];
    final domain = parts.length > 1 ? '@${parts[1]}' : '';

    if (name.length <= 4) {
      final first = name.substring(0, 1);
      final last = name.length > 1 ? name.substring(name.length - 1) : '';
      return '$first....$last$domain';
    }

    final firstTwo = name.substring(0, 2);
    final lastTwo = name.substring(name.length - 2);
    return '$firstTwo....$lastTwo$domain';
  }

  @override
  void initState() {
    super.initState();

    statusCtrl = Get.put(StatusController());

    accountController.fetchUserInfo();
    accountController.fetchWalletAddress();
    accountController.toggleBalanceVisibility();
    accountController.fetchWalletDetails();
    accountController.fetchWalletData();
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userInitial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : '?';

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Post Updates',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 0.6,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USER HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                accountController.avatarName.value.isNotEmpty
                                ? AssetImage(
                                    'assets/images/${accountController.avatarName.value}.png',
                                  )
                                : null,
                            child: accountController.avatarName.value.isEmpty
                                ? Text(
                                    userInitial,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.userName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (Get.find<VerifiedController>()
                                        .isVerified
                                        .value)
                                      Image.asset(
                                        "assets/images/verified.png",
                                        width: 15,
                                        height: 15,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  obfuscateEmail(widget.userEmail),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// COMPOSER
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900.withOpacity(.45)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: TextField(
                          controller: inputCtrl,
                          minLines: 2,
                          maxLines: 5,
                          maxLength: 80,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(
                              18,
                              18,
                              18,
                              18,
                            ),
                            hintText: "Share something with everyone...",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// IMAGE PREVIEW
                      Obx(() {
                        final image = statusCtrl.selectedImageBytes.value;

                        if (image == null) {
                          return const SizedBox.shrink();
                        }

                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.memory(
                                image,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  statusCtrl.selectedImageBytes.value = null;
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 16),

                      /// TOOLBAR
                      Row(
                        children: [
                          /// IMAGE BUTTON
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                statusCtrl.pickImageFromDevice();
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black12,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 20,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Image",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// SEND BUTTON
                          Obx(() {
                            final isPosting = statusCtrl.isPosting.value;

                            return GestureDetector(
                              onTap: isPosting
                                  ? null
                                  : () async {
                                      final text = inputCtrl.text.trim();

                                      await statusCtrl.postStatus(
                                        text,
                                        widget.userName,
                                        widget.userEmail,
                                      );

                                      if (!mounted) return;

                                      inputCtrl.clear();

                                      Get.to(
                                        () => Home(
                                          userName:
                                              accountController.userName.value,
                                          userEmail:
                                              accountController.userEmail.value,
                                        ),
                                      );
                                    },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isPosting
                                      ? Colors.black45
                                      : Colors.black,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.25),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: isPosting
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_upward_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
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
