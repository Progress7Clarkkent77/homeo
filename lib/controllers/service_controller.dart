import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:homeo/controllers/e_login_controller.dart';

/// 🔹 Controlled icon set for HOMEo services.
///
/// The spec asks for a controlled list rather than free-typed icon code,
/// so a service's `icon` field stores one of these keys, and the admin UI
/// only ever lets you pick from this map — never type one in.
const Map<String, IconData> kHomeoServiceIcons = {
  'cleaning_services': Icons.cleaning_services_rounded,
  'child_care': Icons.child_care_rounded,
  'family_restroom': Icons.family_restroom_rounded,
  'home_work': Icons.home_work_rounded,
  'restaurant_menu': Icons.restaurant_menu_rounded,
  'school': Icons.school_rounded,
  'home_repair_service': Icons.home_repair_service_rounded,
  'local_laundry_service': Icons.local_laundry_service_rounded,
  'handyman': Icons.handyman_rounded,
  'pets': Icons.pets_rounded,
  'yard': Icons.yard_rounded,
  'security': Icons.security_rounded,
};

IconData iconForKey(String key) =>
    kHomeoServiceIcons[key] ?? Icons.home_repair_service_rounded;

/// 🔹 Thrown by every admin-gated write on [ServiceController] when
/// `isAdmin.value` is false — e.g. the signed-in account passed the
/// admin *login* screen but doesn't have `isAdmin: true` set on its
/// `e-users/{uid}` Firestore doc yet. Callers should catch this
/// specifically and show an actionable message rather than letting the
/// write silently do nothing.
class NotAdminException implements Exception {
  const NotAdminException();

  @override
  String toString() =>
      'This account is not marked as an admin (e-users/{uid}.isAdmin '
      'is not true in Firestore).';
}

/// Simple immutable model for a HOMEo service document.
///
/// Mirrors the `services/{serviceId}` shape from the product spec:
/// name, description, icon, isActive, likesCount, order, createdAt, updatedAt.
class HomeoServiceModel {
  final String id;
  final String name;
  final String description;
  final String coverage; // "what the service covers" — optional, admin-set
  final String icon;
  final String imageUrl; // optional cover photo — empty means "use the icon"
  final bool isActive;
  final int likesCount;
  final int order;

  HomeoServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverage,
    required this.icon,
    required this.imageUrl,
    required this.isActive,
    required this.likesCount,
    required this.order,
  });

  /// Whether this service has a real cover photo to show, as opposed to
  /// falling back to its icon tile everywhere it's displayed.
  bool get hasImage => imageUrl.trim().isNotEmpty;

  factory HomeoServiceModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HomeoServiceModel(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      coverage: (data['coverage'] ?? '') as String,
      icon: (data['icon'] ?? 'home_repair_service') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      isActive: (data['isActive'] ?? true) as bool,
      likesCount: _asInt(data['likesCount']),
      order: _asInt(data['order']),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  HomeoServiceModel copyWith({int? likesCount}) {
    return HomeoServiceModel(
      id: id,
      name: name,
      description: description,
      coverage: coverage,
      icon: icon,
      imageUrl: imageUrl,
      isActive: isActive,
      likesCount: likesCount ?? this.likesCount,
      order: order,
    );
  }
}

/// 🔹 Shared cover-photo tile for a service. Shows `imageUrl` when the
/// service has one (admin-uploaded), and falls back to the icon tile
/// otherwise — used on Home, the admin list, and Service Details so a
/// service always renders the same way wherever it appears.
class ServiceThumb extends StatelessWidget {
  final HomeoServiceModel service;
  final double size;
  final double radius;
  final double iconSize;

  const ServiceThumb({
    super.key,
    required this.service,
    this.size = 52,
    this.radius = 15,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: const Color(0xFF0E7C66).withOpacity(0.10),
      child: Icon(
        iconForKey(service.icon),
        color: const Color(0xFF0E7C66),
        size: iconSize,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: service.hasImage
            ? Image.network(
                service.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      fallback,
                      const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                errorBuilder: (context, error, stack) => fallback,
              )
            : fallback,
      ),
    );
  }
}

/// Controls the HOMEo service catalogue: loading active services for
/// customers, liking/favoriting a service, and (for admins) full CRUD.
///
/// `toggleServiceLike` follows the same shape as
/// `StatusController.toggleLike` — optimistic local update first, then a
/// Firestore write, then a one-time idempotent r (mirroring
/// `handleStatusLiker`) so a user can't farm rs by repeatedly
/// liking and unliking the same service.
///
/// Collection convention: this codebase stores user records under
/// `e-users` everywhere else (see ThemeController, rController,
/// StatusController, AuthController), so favorites live at
/// `e-users/{uid}/favorites/{serviceId}` — not a separate `users`
/// collection — to stay consistent with the rest of the app.
class ServiceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  /// ✅ Customer-facing state — active services only, in display order.
  final RxList<HomeoServiceModel> services = <HomeoServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString loadError = ''.obs;

  /// ✅ Admin-facing state — every service, active or not, in order.
  final RxList<HomeoServiceModel> adminServices = <HomeoServiceModel>[].obs;
  final RxBool isAdminLoading = false.obs;

  /// ✅ Service ids the current user has liked/favorited.
  /// Empty for a signed-out visitor — browsing never requires login.
  final RxSet<String> likedServiceIds = <String>{}.obs;

  /// ✅ Whether the signed-in user is a HOMEo admin.
  final RxBool isAdmin = false.obs;

  StreamSubscription<QuerySnapshot>? _servicesSub;
  StreamSubscription<QuerySnapshot>? _adminServicesSub;
  StreamSubscription<QuerySnapshot>? _favoritesSub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    loadServices();
    _syncForCurrentUser();

    // AuthController only exposes a `currentUser` getter, not a stream,
    // so we listen to Firebase's own auth state directly to re-sync
    // favorites/admin status on sign-in/sign-out without touching
    // AuthController.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      _syncForCurrentUser();
    });
  }

  @override
  void onClose() {
    _servicesSub?.cancel();
    _adminServicesSub?.cancel();
    _favoritesSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  bool get isSignedIn => _auth.currentUser != null;

  void _syncForCurrentUser() {
    loadUserFavorites();
    _checkAdminStatus();
  }

  // ---------------------------------------------------------------------
  // CUSTOMER: browse
  // ---------------------------------------------------------------------

  /// 🔹 Stream only active services, ordered for display.
  /// Browsing never requires login, so this runs regardless of auth state.
  void loadServices() {
    isLoading.value = true;
    loadError.value = '';

    _servicesSub?.cancel();
    _servicesSub = _firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .listen(
          (snapshot) {
            services.value = snapshot.docs
                .map((d) => HomeoServiceModel.fromDoc(d))
                .toList();
            isLoading.value = false;
          },
          onError: (e) {
            if (kDebugMode) print('❌ Load services error: $e');
            loadError.value = 'Could not load services. Pull down to retry.';
            isLoading.value = false;
          },
        );
  }

  /// 🔹 Stream the signed-in user's favorites so `likedServiceIds` stays
  /// in sync across devices/sessions. Clears immediately on sign-out.
  void loadUserFavorites() {
    _favoritesSub?.cancel();

    final user = _auth.currentUser;
    if (user == null) {
      likedServiceIds.clear();
      return;
    }

    _favoritesSub = _firestore
        .collection('e-users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            likedServiceIds.value = snapshot.docs.map((d) => d.id).toSet();
          },
          onError: (e) {
            if (kDebugMode) print('❌ Load favorites error: $e');
          },
        );
  }

  bool isLiked(String serviceId) => likedServiceIds.contains(serviceId);

  /// 🔹 Like/unlike a service.
  ///
  /// Caller is responsible for the auth-required dialog described in the
  /// spec — if this is invoked while signed out, it safely no-ops so a
  /// stray tap can never write anonymous data.
  Future<void> toggleServiceLike(String serviceId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    final index = services.indexWhere((s) => s.id == serviceId);
    if (index == -1) return;

    final wasLiked = likedServiceIds.contains(serviceId);
    final willLike = !wasLiked;

    /// ✅ INSTANT UI UPDATE (optimistic, same as StatusController.toggleLike)
    if (willLike) {
      likedServiceIds.add(serviceId);
    } else {
      likedServiceIds.remove(serviceId);
    }
    services[index] = services[index].copyWith(
      likesCount: services[index].likesCount + (willLike ? 1 : -1),
    );

    final serviceRef = _firestore.collection('services').doc(serviceId);
    final favoriteRef = _firestore
        .collection('e-users')
        .doc(uid)
        .collection('favorites')
        .doc(serviceId);

    try {
      await _firestore.runTransaction((txn) async {
        final favoriteSnap = await txn.get(favoriteRef);
        final alreadyLiked = favoriteSnap.exists;

        // Guards against duplicate likes if two taps race each other —
        // the transaction re-checks truth from Firestore, not the
        // optimistic local state above.
        if (alreadyLiked == willLike) return;

        if (willLike) {
          txn.set(favoriteRef, {
            'serviceId': serviceId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          txn.update(serviceRef, {'likesCount': FieldValue.increment(1)});
        } else {
          txn.delete(favoriteRef);
          txn.update(serviceRef, {'likesCount': FieldValue.increment(-1)});
        }
      });

      if (willLike) {
        await handleServiceLiker(serviceId: serviceId, userUid: uid);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Toggle service like error: $e');

      // Roll back the optimistic update on failure.
      if (willLike) {
        likedServiceIds.remove(serviceId);
      } else {
        likedServiceIds.add(serviceId);
      }
      final revertIndex = services.indexWhere((s) => s.id == serviceId);
      if (revertIndex != -1) {
        services[revertIndex] = services[revertIndex].copyWith(
          likesCount: services[revertIndex].likesCount + (willLike ? -1 : 1),
        );
      }
    }
  }

  /// 🔹 One-time r for liking a service, mirroring
  /// `StatusController.handleStatusLiker`: a ledger doc under
  /// `servicers/{uid}/serviceLikes/{serviceId}` guards against
  /// ring the same user for the same service more than once, even
  /// if they unlike and re-like it later.
  Future<void> handleServiceLiker({
    required String serviceId,
    required String userUid,
  }) async {
    try {
      final rRef = _firestore
          .collection('servicers')
          .doc(userUid)
          .collection('serviceLikes')
          .doc(serviceId);

      if (!(await rRef.get()).exists) {
        await rRef.set({
          'red': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error ring service like: $e');
    }
  }

  // ---------------------------------------------------------------------
  // ADMIN: gate + CRUD
  // ---------------------------------------------------------------------

  /// 🔹 Re-reads `e-users/{uid}.isAdmin` from Firestore right now, without
  /// requiring the user to sign out and back in. Useful right after
  /// flipping `isAdmin` on for an account in the Firebase console — call
  /// this (e.g. from a "Try again" button) to pick the change up
  /// immediately instead of waiting for the next auth-state change.
  Future<void> refreshAdminStatus() => _checkAdminStatus();

  /// 🔹 Checks `e-users/{uid}.isAdmin`. Kept self-contained (a direct
  /// Firestore read) rather than depending on AccountController, since
  /// that controller's fields aren't visible from ServiceController.
  Future<void> _checkAdminStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      isAdmin.value = false;
      _adminServicesSub?.cancel();
      adminServices.clear();
      return;
    }

    try {
      final doc = await _firestore.collection('e-users').doc(user.uid).get();
      isAdmin.value = (doc.data()?['isAdmin'] ?? false) == true;

      if (isAdmin.value) {
        _loadAdminServices();
      } else {
        _adminServicesSub?.cancel();
        adminServices.clear();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Admin check error: $e');
      isAdmin.value = false;
    }
  }

  /// 🔹 Admins see every service (active or not) so they can re-enable one.
  void _loadAdminServices() {
    isAdminLoading.value = true;

    _adminServicesSub?.cancel();
    _adminServicesSub = _firestore
        .collection('services')
        .orderBy('order')
        .snapshots()
        .listen(
          (snapshot) {
            adminServices.value = snapshot.docs
                .map((d) => HomeoServiceModel.fromDoc(d))
                .toList();
            isAdminLoading.value = false;
          },
          onError: (e) {
            if (kDebugMode) print('❌ Load admin services error: $e');
            isAdminLoading.value = false;
          },
        );
  }

  /// 🔹 Add a new service. `order` defaults to the end of the current list
  /// so new services appear last until an admin repositions them.
  Future<void> addService({
    required String name,
    required String description,
    required String coverage,
    required String iconKey,
    String imageUrl = '',
  }) async {
    if (!isAdmin.value) throw const NotAdminException();

    final nextOrder = adminServices.isEmpty
        ? 0
        : (adminServices.map((s) => s.order).reduce((a, b) => a > b ? a : b) +
              1);

    await _firestore.collection('services').add({
      'name': name.trim(),
      'description': description.trim(),
      'coverage': coverage.trim(),
      'icon': iconKey,
      'imageUrl': imageUrl.trim(),
      'isActive': true,
      'likesCount': 0,
      'order': nextOrder,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Edit name/description/coverage/icon for an existing service.
  Future<void> updateService({
    required String serviceId,
    required String name,
    required String description,
    required String coverage,
    required String iconKey,
    String? imageUrl,
  }) async {
    if (!isAdmin.value) throw const NotAdminException();

    final update = <String, dynamic>{
      'name': name.trim(),
      'description': description.trim(),
      'coverage': coverage.trim(),
      'icon': iconKey,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Only touch imageUrl when the caller actually passed one — `null`
    // means "leave the existing photo alone", while an empty string is
    // an explicit "remove the photo" from the editor.
    if (imageUrl != null) {
      update['imageUrl'] = imageUrl.trim();
    }

    await _firestore.collection('services').doc(serviceId).update(update);
  }

  /// 🔹 Enable/disable a service. Disabled services drop out of the
  /// customer-facing catalogue immediately (the `isActive` query filter).
  Future<void> setServiceActive(String serviceId, bool isActive) async {
    if (!isAdmin.value) throw const NotAdminException();

    await _firestore.collection('services').doc(serviceId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Deletes a service outright. Prefer `setServiceActive(id, false)`
  /// for routine deactivation — this is for permanent removal.
  Future<void> deleteService(String serviceId) async {
    if (!isAdmin.value) throw const NotAdminException();

    await _firestore.collection('services').doc(serviceId).delete();
  }

  /// 🔹 Persists a full reordering (e.g. after a drag-and-drop reorder in
  /// the admin UI). Pass the services in their new display order.
  Future<void> reorderServices(List<HomeoServiceModel> newOrder) async {
    if (!isAdmin.value) throw const NotAdminException();

    final batch = _firestore.batch();
    for (var i = 0; i < newOrder.length; i++) {
      batch.update(_firestore.collection('services').doc(newOrder[i].id), {
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
