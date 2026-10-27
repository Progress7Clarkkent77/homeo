import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:homeo/controllers/contact_config_controller.dart';
import 'package:homeo/controllers/service_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/pages/home.dart' show kHomeoPrimary, HomeoApprovedBadge;

/// 🔹 Premium Service Details page.
///
/// Streams the service doc live by [serviceId] (rather than taking a
/// snapshot model) so edits from the admin page reflect immediately
/// without the user needing to go back and re-open it.
class ServiceDetailsPage extends StatelessWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final contactCtrl = Get.put(ContactConfigController(), permanent: true);

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8F7),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Service Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('services')
              .doc(serviceId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kHomeoPrimary),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _NotFoundState(isDark: isDark);
            }

            final service = HomeoServiceModel.fromDoc(snapshot.data!);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Premium full-width hero image. Cropped to fill the
                  // frame edge-to-edge (no letterboxing) regardless of the
                  // underlying thumb's native aspect ratio.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: 340,
                          height: 340,
                          child: ServiceThumb(
                            service: service,
                            size: 340,
                            radius: 0,
                            iconSize: 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Text(
                      service.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF14171A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Reviewed and approved by the HOMEo team',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'About this service',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF14171A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  if (service.coverage.trim().isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      'What this service covers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF14171A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.coverage,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.6,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  _ContactCard(
                    isDark: isDark,
                    serviceName: service.name,
                    contactCtrl: contactCtrl,
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class _ContactCard extends StatelessWidget {
  final bool isDark;
  final String serviceName;
  final ContactConfigController contactCtrl;

  const _ContactCard({
    required this.isDark,
    required this.serviceName,
    required this.contactCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16191D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact HOMEo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF14171A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'HOMEo handles booking directly — reach out and our team '
            'will take care of the rest.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () =>
                  contactCtrl.openWhatsApp(serviceName: serviceName),
              icon: const Icon(Icons.chat, color: Colors.white, size: 18),
              label: const Text(
                'WhatsApp HOMEo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: kHomeoPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: contactCtrl.callHomeo,
              icon: const Icon(
                Icons.call_rounded,
                color: kHomeoPrimary,
                size: 18,
              ),
              label: const Text(
                'Call HOMEo',
                style: TextStyle(
                  color: kHomeoPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  final bool isDark;
  const _NotFoundState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'This service is no longer available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
