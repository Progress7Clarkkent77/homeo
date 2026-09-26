import 'package:homeo/controllers/e_login_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class spiiiqRewardPolicyScreen extends StatefulWidget {
  spiiiqRewardPolicyScreen({super.key});

  @override
  State<spiiiqRewardPolicyScreen> createState() =>
      _spiiiqRewardPolicyScreenState();
}

class _spiiiqRewardPolicyScreenState extends State<spiiiqRewardPolicyScreen> {
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _markPolicyAsSeen();
  }

  Future<void> _markPolicyAsSeen() async {
    final userId = authController
        .currentUser!
        .uid; // or FirebaseAuth.instance.currentUser!.uid

    await _firestore.collection('e-users').doc(userId).update({
      'policySeen': true,
      'policySeenAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.black : Colors.white,

          /// 👇 CUSTOM BACK BUTTON
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Get.offNamed('/home');
            },
          ),

          title: Text(
            'Reward Policy',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Center(
            child: Container(
              width: 720,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _policyContent(isDark),
            ),
          ),
        ),
      );
    });
  }

  Widget _policyContent(bool isDark) {
    TextStyle header = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: isDark ? Colors.white : Colors.black,
    );

    TextStyle body = TextStyle(
      fontSize: 14,
      height: 1.7,
      color: isDark ? Colors.white70 : Colors.black87,
    );

    TextStyle italicBody = TextStyle(
      fontSize: 12.5,
      height: 1.5,
      fontStyle: FontStyle.italic,
      color: isDark ? Colors.white60 : Colors.black54,
    );

    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Text('spiiiq Reward Policy', style: header),
    //     const SizedBox(height: 12),
    //     Text(
    //       'Welcome to spiiiq  \nA voice-only social platform powered by a proprietary blockchain technology, where meaningful engagement earns real, withdrawable rewards.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 22),
    //     Text('1. How Rewards Are Earned', style: header),
    //     const SizedBox(height: 8),
    //     Text(
    //       'Users earn rewards when their activity generates genuine engagement such as reactions, comments on posts, or interacting with sponsored ads. '
    //       'Engaging and following us on X also contributes to earning additional rewards. '
    //       'Rewards are credited automatically and can be withdrawn at any time. '
    //       'Verified users earn triple (3×) rewards on all eligible actions.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 20),
    //     Text('2. Activities That Do Not Earn Rewards', style: header),
    //     const SizedBox(height: 8),
    //     Text(
    //       'Messages without replies, posts with no engagement, spam, coordinated farming, or activity beyond daily limits do not earn rewards. '
    //       'spiiiq rewards quality interaction, not volume.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 20),
    //     Text('3. Limits & Fair Use', style: header),
    //     const SizedBox(height: 8),
    //     Text(
    //       'Daily earning caps apply. Posting frequency is limited to ensure fairness. '
    //       'Verified Gold badge is paid and verified. Abuse detection systems may reduce or revoke rewards.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 20),
    //     Text('4. Withdrawals', style: header),
    //     const SizedBox(height: 8),
    //     Text(
    //       'Rewards are real and withdrawable, subject to minimum withdrawal limits, verification, and processing rules.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 20),
    //     Text('5. Verified Badge', style: header),
    //     const SizedBox(height: 8),
    //     Text(
    //       'Verified users earn 3× rewards, receive platform recognition, and enjoy priority support. '
    //       'Verification promotes trust and platform quality.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 20),
    //     Text('6. Agreement & Updates', style: header),
    //     const SizedBox(height: 8),
    //     Text(
    //       'By using spiiiq, you agree to engage honestly and follow platform rules. '
    //       'spiiiq reserves the right to update reward and verification policies to protect the community.',
    //       style: body,
    //     ),
    //     const SizedBox(height: 24),

    //     /// 🔹 Powered By
    //     Center(
    //       child: Text(
    //         'Powered by Progress Blockchain',
    //         style: italicBody,
    //       ),
    //     ),
    //   ],
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SPIIIQ Reward Policy', style: header),
        const SizedBox(height: 12),
        Text(
          'Welcome to SPIIIQ.\n\n'
          'SPIIIQ is a social platform where users express themselves through text and picture posts. '
          'Our reward system is designed to encourage authentic participation, meaningful conversations, '
          'and quality content while protecting the platform from abuse.\n\n'
          'Rewards are subject to eligibility requirements, earning limits, and the terms of this policy.',
          style: body,
        ),

        const SizedBox(height: 22),
        Text('1. Earning Rewards', style: header),
        const SizedBox(height: 8),
        Text(
          'Users may earn rewards through eligible activities, including:\n\n'
          '• Publishing original text posts.\n'
          '• Publishing original picture posts.\n'
          '• Receiving genuine likes on eligible posts.\n'
          '• Receiving meaningful comments on eligible posts.\n'
          '• Participating in official SPIIIQ campaigns and promotions.\n\n'
          'Rewards are calculated automatically according to SPIIIQ’s reward rules and are subject to '
          'authenticity checks, applicable limits, and account eligibility. '
          'Posting content or receiving engagement does not guarantee a reward.',
          style: body,
        ),

        const SizedBox(height: 20),
        Text('2. Ineligible Activities', style: header),
        const SizedBox(height: 8),
        Text(
          'The following activities do not qualify for rewards:\n\n'
          '• Spam, repetitive, copied, or low-quality posts intended to exploit the reward system.\n'
          '• Artificial engagement, engagement exchanges, or reward farming.\n'
          '• Fake accounts, bots, scripts, or automated activity.\n'
          '• Self-generated likes, comments, or other engagement.\n'
          '• Content that violates SPIIIQ’s Community Guidelines or applicable policies.\n'
          '• Misleading, fraudulent, or manipulated engagement.\n'
          '• Any activity identified as an attempt to abuse or manipulate the reward system.',
          style: body,
        ),

        const SizedBox(height: 20),
        Text('3. Fair Use and Reward Integrity', style: header),
        const SizedBox(height: 8),
        Text(
          'SPIIIQ monitors platform activity to help maintain fairness and protect the reward system. '
          'Daily earning limits, posting limits, eligibility requirements, and fraud-detection measures '
          'may be applied to ensure that rewards are associated with genuine participation.\n\n'
          'SPIIIQ may review suspicious activity, withhold or reverse improperly obtained rewards, '
          'restrict reward eligibility, temporarily limit an account, or suspend accounts involved in abuse. '
          'Actions will be taken in accordance with applicable SPIIIQ policies.',
          style: body,
        ),

        const SizedBox(height: 20),
        Text('4. Verified Accounts', style: header),
        const SizedBox(height: 8),
        Text(
          'Verified accounts may receive additional visibility within SPIIIQ’s discovery or content feeds. '
          'Verification helps establish account authenticity but does not guarantee engagement, earnings, '
          'or eligibility for any particular reward.\n\n'
          'Verified users remain subject to the same reward requirements, authenticity checks, '
          'and Community Guidelines as other users.',
          style: body,
        ),

        const SizedBox(height: 20),
        Text('5. Withdrawals', style: header),
        const SizedBox(height: 8),
        Text(
          'Eligible rewards may be withdrawn once the applicable minimum withdrawal requirement has been met. '
          'Withdrawals are subject to account eligibility, identity or account verification where required, '
          'security reviews, processing requirements, and applicable SPIIIQ policies.\n\n'
          'A withdrawal may be delayed or declined where additional review is necessary or where the account '
          'or rewards do not meet the applicable requirements.',
          style: body,
        ),

        const SizedBox(height: 20),
        Text('6. Changes to the Reward System', style: header),
        const SizedBox(height: 8),
        Text(
          'SPIIIQ may modify, pause, or discontinue reward activities, earning rates, limits, eligibility '
          'requirements, or promotional campaigns to address fairness, security, operational, or business needs. '
          'Where appropriate, users will be notified of material changes.\n\n'
          'The version of this policy in effect at the relevant time will govern reward activity, '
          'subject to applicable law.',
          style: body,
        ),

        const SizedBox(height: 24),
        Center(child: Text('Powered by AFIA SPLENDID LTD', style: italicBody)),
      ],
    );
  }
}
