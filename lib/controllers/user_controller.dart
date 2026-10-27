import 'package:homeo/controllers/e_login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToUsers();
  }

  void _listenToUsers() {
    _firestore.collection('e-users').snapshots().listen((snapshot) {
      final currentUid = _auth.currentUser?.uid;
      users.value = snapshot.docs.where((doc) => doc.id != currentUid).toList();
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get filteredUsers {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return users;

    return users.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void toggleSearch() {
    isSearching.toggle();
    if (!isSearching.value) searchQuery.value = '';
  }

  /// 🔹 Public getter for the current Firebase user
  User? get currentUser => _auth.currentUser;
}
