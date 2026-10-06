import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// =====================================================================
/// TERMS OF USE / EULA GATE — PRE-LOGIN GATE VERSION
/// ---------------------------------------------------------------------
/// Shown as soon as AuthController.login() has verified the entered
/// email/password against Firebase Auth but found that the matching
/// e-users doc does not yet have 'termsAccepted' == true. Login is
/// intentionally left incomplete at that point — no FCM token save, no
/// presence update, no theme/chat setup, no navigation to '/home' — so
/// this screen is the only thing standing between the user and their
/// account.
///
/// On accept: writes 'termsAccepted' + 'termsAcceptedAt' to the user's
/// e-users doc, signs the user back out, and returns to '/login'. The
/// user must then log in again; on that second attempt
/// AuthController.login() will see termsAccepted == true and complete
/// the full login flow normally.
///
/// On decline: signs the user out and returns to '/login' without
/// recording acceptance, so the next login attempt hits this gate again.
///
/// Firestore (not SharedPreferences) is the source of truth here since
/// nothing on this screen runs before Firebase Auth already has a
/// signed-in user — this also means acceptance follows the account
/// across devices/reinstalls.
///
/// Wire-up: called via Get.off(() => const TermsOfUseScreen()) from
/// AuthController.login().
/// =====================================================================
class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  bool hasReadTerms = false;
  bool hasReadPrivacy = false;
  bool isSaving = false;

  bool get canContinue => hasReadTerms && hasReadPrivacy && !isSaving;

  Future<void> _acceptAndContinue() async {
    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('e-users').doc(user.uid).set({
        'termsAccepted': true,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // The user only reached this screen because their prior login attempt
    // was intentionally left incomplete (see AuthController.login()) — no
    // presence/theme/chat setup was ever run for this session. Now that
    // termsAccepted is recorded, sign them back out and send them to the
    // login page so they log in again to actually complete the login flow.
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    setState(() => isSaving = false);
    Get.offAllNamed('/login');
  }

  void _decline() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Terms Required',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You need to accept the Terms of Use to continue using Textido. '
          'You can review the terms again before deciding.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Review Again'),
          ),
          TextButton(
            onPressed: () async {
              // User already has an account and is signed in at this
              // point, so declining signs them back out rather than
              // force-closing the app.
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Requirement: white background, black text
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terms of Use',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please read and accept before continuing',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // ---------------- SCROLLABLE TERMS TEXT ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Text(
                  _termsOfUseText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // ---------------- CHECKBOXES + ACTIONS ----------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCheckRow(
                    value: hasReadTerms,
                    label: 'I have read and agree to the Textido Terms of Use.',
                    onChanged: (v) => setState(() => hasReadTerms = v ?? false),
                  ),
                  _buildCheckRow(
                    value: hasReadPrivacy,
                    label: 'I acknowledge that I have also read the Privacy Policy.',
                    onChanged: (v) =>
                        setState(() => hasReadPrivacy = v ?? false),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canContinue ? _acceptAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accept & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _decline,
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              activeColor: Colors.black,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _termsOfUseText = '''
HOMEo Terms of Use

Last Updated: October 6, 2026

Welcome to HOMEo, a managed home-services platform operated by AfiaSplendid LTD ("AfiaSplendid," "HOMEo," "we," "our," or "us").

HOMEo is designed to help customers discover and request household services from professionals who are recruited, screened, and managed through our service process.

By accessing or using HOMEo, you acknowledge that you have read, understood, and agree to these Terms of Use. If you do not agree with these Terms, you must not use HOMEo.

1. About HOMEo

HOMEo is a managed home-services platform that helps customers access household services through AfiaSplendid LTD.

Our services may include:

- Cleaning services.
- Babysitting services.
- Nanny services.
- Maid services.
- Chef or cooking services.
- Home tutoring or lesson services.

Service categories, availability, locations, pricing, and other offerings may change from time to time.

HOMEo does not operate as an open marketplace where anyone can freely register and offer services to customers.

2. Eligibility

You must be at least 18 years of age to independently request or arrange services through HOMEo.

If you are under 18, you may only use HOMEo with the involvement and permission of a parent or legal guardian where permitted by applicable law.

3. Acceptance of These Terms

By accessing HOMEo, creating an account, requesting a service, contacting HOMEo, or otherwise using the platform, you agree to these Terms of Use, our Privacy Policy, and any additional policies or service-specific terms that may apply.

4. Browsing and Service Information

HOMEo may allow users to browse available service categories and view information about the services offered.

Service descriptions, prices, availability, coverage areas, images, and other information displayed through HOMEo are provided for informational and service-planning purposes.

Information may change based on availability, staffing, location, service requirements, and other operational factors.

5. Service Requests

Submitting a service request or contacting HOMEo does not automatically guarantee that a service will be available or confirmed.

Before a service is provided, HOMEo may need to confirm:

- Service type.
- Customer location.
- Preferred date and time.
- Service requirements.
- Availability of an appropriate professional.
- Applicable service price.
- Other relevant arrangements.

A service is considered confirmed only after HOMEo communicates confirmation to the customer.

6. Service Professionals

HOMEo may recruit, interview, screen, assess, and manage professionals who provide services through the platform.

The screening and verification process may include information such as:

- Identity information.
- Contact information.
- Experience.
- Skills.
- References.
- Other information relevant to the service.

Although we take reasonable steps to assess professionals before assigning them to customers, no screening process can guarantee a person's future conduct, performance, or suitability in every situation.

7. Professional Assignment

HOMEo may determine which professional is assigned to a service request based on factors including:

- Service type.
- Location.
- Availability.
- Experience.
- Skills.
- Customer requirements.
- Other operational considerations.

Customers may communicate specific preferences or requirements, but HOMEo cannot guarantee that a particular professional will always be available or assigned.

8. Customer Responsibilities

Customers using HOMEo agree to:

- Provide accurate information.
- Provide accurate service location details.
- Provide reasonable access to the premises where required.
- Clearly communicate relevant service requirements.
- Treat service professionals with respect.
- Provide a safe environment for service professionals.
- Follow applicable laws and regulations.
- Avoid abusive, threatening, discriminatory, or inappropriate behavior.

Customers must not knowingly provide false information or request services for unlawful purposes.

9. Service Environment and Safety

Customers are responsible for informing HOMEo of any relevant circumstances that may reasonably affect the safety of a service professional or the performance of a service.

Customers must not knowingly expose professionals to dangerous conditions, unlawful activities, weapons, hazardous materials, or other serious risks.

HOMEo may refuse, suspend, or terminate a service where we reasonably believe that the working environment presents an unacceptable safety risk.

10. Service Quality

We aim to provide reliable and professional services.

However, service outcomes may vary depending on:

- Property size and condition.
- Service requirements.
- Time allocated.
- Materials or equipment available.
- Customer instructions.
- Other circumstances affecting the service.

HOMEo does not guarantee that every service will meet every individual preference or expectation.

Where a customer has a legitimate concern regarding a service, they should contact HOMEo so that the matter can be reviewed.

11. Pricing and Service Charges

Service prices may depend on factors such as:

- Type of service.
- Property size.
- Service duration.
- Location.
- Number of professionals required.
- Specific customer requirements.
- Additional services requested.

Prices may change from time to time.

Where applicable, the customer will be informed of the applicable price before the service is confirmed.

Additional services or requirements may result in additional charges where agreed or reasonably applicable.

12. Payments

Where payment is required for a HOMEo service, customers will be provided with the applicable payment instructions or payment method.

Customers should only make payments through payment channels officially communicated by HOMEo or AfiaSplendid LTD.

Customers should not send money to individuals claiming to represent HOMEo through unofficial channels.

13. Cancellations and Rescheduling

Customers may contact HOMEo to request cancellation or rescheduling of a service.

Cancellation or rescheduling may be subject to the timing of the request, service status, professional availability, and any applicable cancellation policy.

If a professional has already been assigned, dispatched, or begun travelling to the service location, additional conditions may apply.

14. Refunds

Where a refund is applicable, it will be handled according to the circumstances of the service and any applicable refund policy.

Refunds may be considered where:

- A confirmed service was cancelled by HOMEo.
- A qualifying payment was made for a service that was not provided.
- A billing or payment error occurred.
- Another circumstance reasonably requires a refund.

Refund eligibility may depend on the specific service and circumstances.

Nothing in these Terms removes any consumer rights that cannot legally be excluded.

15. Prohibited Conduct

Users must not use HOMEo to:

- Harass, threaten, abuse, or intimidate professionals or other users.
- Discriminate against professionals based on unlawful grounds.
- Request unlawful services.
- Provide false information.
- Attempt to bypass HOMEo to unlawfully interfere with service arrangements.
- Engage in fraud or fraudulent transactions.
- Use HOMEo to facilitate criminal activity.
- Attempt unauthorized access to HOMEo systems.
- Interfere with the security or operation of the platform.
- Misuse customer or professional information.
- Record, publish, or distribute private information about professionals or customers without appropriate authorization or lawful basis.

Violations may result in service cancellation, account restrictions, suspension, or termination.

16. Complaints and Disputes

Customers who have concerns regarding a service, professional, payment, or interaction should contact HOMEo as soon as reasonably possible.

We may investigate complaints and communicate with the customer and, where appropriate, the relevant professional.

Depending on the circumstances, HOMEo may:

- Request additional information.
- Review the service arrangement.
- Contact the relevant parties.
- Arrange a corrective action.
- Restrict future service access.
- Take other appropriate action.

17. Account Suspension and Termination

We may suspend or terminate access to HOMEo where a user:

- Violates these Terms.
- Engages in fraudulent activity.
- Provides false information.
- Abuses professionals or other users.
- Creates a safety risk.
- Engages in unlawful conduct.
- Attempts to compromise the platform.
- Repeatedly misuses HOMEo services.

Serious violations may result in immediate restriction or termination.

18. Intellectual Property

The HOMEo name, logo, software, design, graphics, interface, service presentation, and other original materials are owned by or licensed to AfiaSplendid LTD and are protected by applicable intellectual property laws.

You may not copy, reproduce, modify, distribute, reverse engineer, or commercially exploit any part of HOMEo without prior written permission.

19. Privacy

Your use of HOMEo is also governed by our Privacy Policy.

Our Privacy Policy explains how information associated with your use of HOMEo may be collected, used, stored, processed, and protected.

20. Third-Party Services

HOMEo may use third-party services for communication, payments, hosting, technology, analytics, customer support, transportation, or other operational purposes.

Third-party services may have their own terms and privacy policies.

HOMEo is not responsible for the independent policies or actions of third-party services outside our reasonable control.

21. Availability of Service

We aim to provide reliable access to HOMEo, but we do not guarantee that the platform or every service will always be available.

Service availability may be affected by:

- Professional availability.
- Location.
- Weather.
- Emergencies.
- Technical issues.
- Operational limitations.
- Public holidays.
- Other circumstances outside our reasonable control.

We may modify, suspend, or discontinue features or services when necessary.

22. Disclaimer

HOMEo is provided on an "as is" and "as available" basis to the fullest extent permitted by applicable law.

We do not guarantee that:

- Every requested service will always be available.
- A particular professional will always be available.
- Services will always be provided at a particular time unless expressly confirmed.
- Service results will always meet every individual expectation.
- The platform will always operate without technical issues.

23. Limitation of Liability

To the fullest extent permitted by applicable law, AfiaSplendid LTD and HOMEo shall not be liable for indirect, incidental, consequential, special, or other damages arising from or related to:

- Use or inability to use HOMEo.
- Service delays caused by circumstances outside our reasonable control.
- Third-party services.
- Customer-provided information that is inaccurate or incomplete.
- Unauthorized access caused by circumstances outside our reasonable control.
- Technical interruptions or failures.

Nothing in these Terms excludes or limits liability that cannot legally be excluded or limited.

24. Changes to These Terms

We may update these Terms of Use from time to time to reflect changes in our services, technology, operations, or legal requirements.

Where significant changes are made, we may notify users through HOMEo or another reasonable communication method.

Your continued use of HOMEo after updated Terms become effective constitutes acceptance of the revised Terms, where permitted by law.

25. Governing Law

These Terms shall be governed by the applicable laws of the jurisdiction in which AfiaSplendid LTD operates, subject to any mandatory consumer rights and protections that may apply.

26. Contact Us

If you have questions regarding these Terms of Use, our services, service requests, or complaints, please contact us:

AfiaSplendid LTD

Email: contact@afiasplendid.co.site

Website: https://afiasplendid.ltd
''';