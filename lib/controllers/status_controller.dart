// import 'dart:async';
// import 'dart:io';

// import 'package:audioplayers/audioplayers.dart' show AudioPlayer;
// import 'package:flutter/foundation.dart';
// //import 'package:just_audio/just_audio.dart';
// import 'package:record/record.dart';
// import 'package:spiiiq/controllers/account_controller.dart';
// import 'package:spiiiq/controllers/e_login_controller.dart';
// import 'package:spiiiq/controllers/r_controller.dart';
// import 'package:spiiiq/controllers/theme_controller.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class StatusController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController _auth = Get.find<AuthController>();
//   final rController _rCtrl = Get.find<rController>();

//   /// ✅ CACHE
//   final RxMap<String, String?> _avatarCache = <String, String?>{}.obs;
//   final RxMap<String, bool> _verifiedCache = <String, bool>{}.obs;

//   /// ✅ UI
//   final RxString searchQuery = ''.obs;
//   final RxList<DocumentSnapshot> statuses = <DocumentSnapshot>[].obs;
//   final Rx<DateTime?> lastStatusPostAt = Rx<DateTime?>(null);

//   /// ✅ IMAGE
//   final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
//   final ImagePicker _picker = ImagePicker();

//   /// AUDIO
//   final AudioPlayer audioPlayer = AudioPlayer();
//   final AudioRecorder recorder = AudioRecorder();

//   final RxBool isRecording = false.obs;
//   final RxBool hasRecordedAudio = false.obs;

//   final Rx<Uint8List?> recordedAudioBytes = Rx<Uint8List?>(null);
//   final RxString audioExtension = ''.obs;

//   Timer? recordingTimer;
//   Timer? _amplitudeTickTimer;

//   /// ✅ PAGINATION
//   final RxInt visibleCount = 10.obs;
//   final RxBool isLoadingMore = false.obs;
//   final int maxLimit = 300;

//   /// ✅ SMART LOADING
//   final RxBool isInitialLoading = true.obs;

//   StreamSubscription<QuerySnapshot>? _statusSubscription;

//   final RxInt recordDuration = 0.obs;

//   final RxBool isPosting = false.obs;

//   @override
//   void onInit() {
//     super.onInit();

//     /// ✅ LOAD IMMEDIATELY
//     _listenToStatuses();

//     /// ✅ LOAD LAST POST DATE
//     _loadLastPostDate();
//   }

//   @override
//   void onClose() {
//     _statusSubscription?.cancel();
//     recordingTimer?.cancel();
//     _amplitudeTickTimer?.cancel();
//     recorder.dispose();
//     audioPlayer.dispose();
//     super.onClose();
//   }

//   Future<void> loadMore() async {
//     if (isLoadingMore.value) return;

//     if (visibleCount.value >= filteredStatuses.length) return;

//     isLoadingMore.value = true;

//     await Future.delayed(const Duration(milliseconds: 200));

//     visibleCount.value += 10;

//     if (visibleCount.value > maxLimit) {
//       visibleCount.value = maxLimit;
//     }

//     isLoadingMore.value = false;
//   }

//   /// 🚀 ULTRA FAST STATUS LOADER FOR WEB PRODUCTION
//   void _listenToStatuses() {
//     _statusSubscription?.cancel();

//     _statusSubscription = _firestore
//         .collection('status1')
//         .orderBy('timestamp', descending: true)
//         /// ✅ LIMIT FIRST LOAD
//         .limit(maxLimit)
//         /// ✅ INCLUDE CACHE FOR WEB SPEED
//         .snapshots(includeMetadataChanges: true)
//         .listen(
//           (snapshot) {
//             final docs = snapshot.docs;

//             /// ✅ LOAD STATUSES IMMEDIATELY
//             statuses.assignAll(docs);

//             /// ✅ PRELOAD COMMENT COUNTS
//             preloadCommentCounts();

//             /// ✅ REMOVE LOADING IMMEDIATELY
//             if (isInitialLoading.value) {
//               isInitialLoading.value = false;
//             }

//             /// ✅ BACKGROUND CACHE LOADING
//             _preloadUserData(docs);
//           },
//           onError: (e) {
//             if (kDebugMode) print('❌ Status stream error: $e');

//             isInitialLoading.value = false;
//           },
//         );
//   }

//   /// ✅ BACKGROUND PRELOAD
//   Future<void> _preloadUserData(List<QueryDocumentSnapshot> docs) async {
//     try {
//       final Set<String> emails = {};

//       for (final doc in docs) {
//         final data = doc.data() as Map<String, dynamic>;

//         final email = (data['email'] ?? '').toString();

//         if (email.isNotEmpty) {
//           emails.add(email);
//         }
//       }

//       if (emails.isEmpty) return;

//       /// ✅ FETCH IN PARALLEL
//       await Future.wait(
//         emails.map((email) async {
//           try {
//             /// VERIFIED
//             if (!_verifiedCache.containsKey(email)) {
//               final verified = await fetchUserVerifiedStatus(email);
//               _verifiedCache[email] = verified;
//             }

//             /// AVATAR
//             if (!_avatarCache.containsKey(email)) {
//               final avatar = await fetchStatusUserAvatarName(email);
//               _avatarCache[email] = avatar;
//             }
//           } catch (e) {
//             if (kDebugMode) print('❌ Cache preload error for $email: $e');
//           }
//         }),
//       );

//       /// ✅ FORCE UI REFRESH
//       statuses.refresh();
//     } catch (e) {
//       if (kDebugMode) print('❌ Background preload error: $e');
//     }
//   }

//   String? getCachedAvatar(String email) {
//     return _avatarCache[email];
//   }

//   bool getCachedVerified(String email) {
//     return _verifiedCache[email] ?? false;
//   }

//   void _loadLastPostDate() async {
//     try {
//       final user = _auth.currentUser;

//       if (user == null) return;

//       final doc = await _firestore
//           .collection('e-users')
//           .doc(user.uid)
//           .get(const GetOptions(source: Source.serverAndCache));

//       final ts = doc.data()?['lastStatusPostAt'] as Timestamp?;

//       lastStatusPostAt.value = ts?.toDate();
//     } catch (e) {
//       if (kDebugMode) print('❌ Error loading last post date: $e');
//     }
//   }

//   Future<void> pickImageFromDevice() async {
//     try {
//       final XFile? picked = await _picker.pickImage(
//         source: ImageSource.gallery,

//         /// ✅ WEB OPTIMIZATION
//         imageQuality: 75,
//       );

//       if (picked != null) {
//         selectedImageBytes.value = await picked.readAsBytes();
//       }
//     } catch (e) {
//       if (kDebugMode) print("❌ Web image pick error: $e");
//     }
//   }

//   Future<void> startVoiceRecording() async {
//     try {
//       if (await recorder.hasPermission() == false) {
//         Get.snackbar("Permission", "Microphone permission denied.");
//         return;
//       }

//       final config = RecordConfig(
//         encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
//         bitRate: 128000,
//         sampleRate: 44100,
//       );

//       // NOTE: On web, the "path" argument is ignored by the plugin (the
//       // browser records to an in-memory Blob and hands back a blob: URL
//       // from recorder.stop()). Passing a path is harmless but only used
//       // on native platforms.
//       await recorder.start(config, path: "status_voice1");

//       isRecording.value = true;
//       recordDuration.value = 0;

//       _amplitudeTickTimer?.cancel();
//       _amplitudeTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         if (!isRecording.value) {
//           timer.cancel();
//           return;
//         }

//         recordDuration.value++;

//         if (recordDuration.value >= 30) {
//           timer.cancel();
//         }
//       });

//       recordingTimer?.cancel();
//       recordingTimer = Timer(const Duration(seconds: 30), () async {
//         if (isRecording.value) {
//           await stopVoiceRecording();
//         }
//       });
//     } catch (e) {
//       if (kDebugMode) print("❌ Start recording error: $e");
//     }
//   }

//   Future<void> stopVoiceRecording() async {
//     try {
//       final path = await recorder.stop();

//       isRecording.value = false;
//       recordDuration.value = 30;

//       recordingTimer?.cancel();
//       _amplitudeTickTimer?.cancel();

//       if (path == null) return;

//       final bytes = await _readRecordedBytes(path);

//       if (bytes == null) return;

//       recordedAudioBytes.value = bytes;
//       hasRecordedAudio.value = true;
//       audioExtension.value = kIsWeb ? "webm" : "m4a";
//     } catch (e) {
//       if (kDebugMode) print("❌ Stop recording error: $e");
//     }
//   }

//   /// ✅ WEB-SAFE + NATIVE-SAFE BYTE READER
//   ///
//   /// This is the fix for `Unsupported operation: _Namespace`.
//   /// `dart:io`'s `File` class does not exist on Flutter Web — calling it
//   /// there throws that exact error. On web, `recorder.stop()` returns a
//   /// `blob:` URL, which must be fetched with an HTTP client instead.
//   Future<Uint8List?> _readRecordedBytes(String path) async {
//     try {
//       if (kIsWeb) {
//         final response = await http.get(Uri.parse(path));

//         if (response.statusCode == 200) {
//           return response.bodyBytes;
//         }

//         if (kDebugMode) {
//           print("❌ Failed to fetch recorded blob: ${response.statusCode}");
//         }

//         return null;
//       }

//       // Native (Android/iOS/desktop): dart:io's File is safe to use here
//       // because this branch never runs when kIsWeb is true. dart:io itself
//       // compiles fine on web (it ships web stubs) — it's *calling* File's
//       // real I/O methods on web that throws "Unsupported operation:
//       // _Namespace", which is exactly the crash you were seeing.
//       final file = File(path);
//       return await file.readAsBytes();
//     } catch (e) {
//       if (kDebugMode) print("❌ Error reading recorded audio bytes: $e");
//       return null;
//     }
//   }

//   void removeRecordedVoice() {
//     recordedAudioBytes.value = null;
//     hasRecordedAudio.value = false;
//     audioExtension.value = "";
//   }

//   Future<String?> _uploadStatusImage(Uint8List bytes, String uid) async {
//     try {
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('status_images1')
//           .child('${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

//       /// ✅ FAST WEB CACHE
//       final metadata = SettableMetadata(
//         contentType: 'image/jpeg',
//         cacheControl: 'public,max-age=31536000',
//       );

//       await ref.putData(bytes, metadata);

//       return await ref.getDownloadURL();
//     } catch (e) {
//       if (kDebugMode) print("❌ Upload error: $e");
//       return null;
//     }
//   }

//   Future<String?> uploadVoice(Uint8List bytes, String uid) async {
//     try {
//       final extension = audioExtension.value;

//       final ref = FirebaseStorage.instance
//           .ref()
//           .child("status_audio1")
//           .child("${uid}_${DateTime.now().millisecondsSinceEpoch}.$extension");

//       await ref.putData(
//         bytes,
//         SettableMetadata(
//           contentType: kIsWeb ? "audio/webm" : "audio/mp4",
//           cacheControl: "public,max-age=31536000",
//         ),
//       );

//       return await ref.getDownloadURL();
//     } catch (e) {
//       if (kDebugMode) print("❌ Upload voice error: $e");
//       return null;
//     }
//   }

//   Future<void> postStatus(
//     String text,
//     String userName,
//     String userEmail,
//   ) async {
//     if (text.trim().isEmpty && selectedImageBytes.value == null) {
//       return;
//     }

//     // 🔧 FIX: guards against rapid double-taps firing two posts.
//     if (isPosting.value) return;
//     isPosting.value = true;

//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final userRef = _firestore.collection('e-users').doc(user.uid);
//       final userSnap = await userRef.get();
//       final data = userSnap.data() ?? {};

//       final Timestamp? lastTs = data['lastStatusPostAt'];
//       int dailyCount = data['dailyPostCount'] ?? 0;
//       final now = DateTime.now();

//       if (lastTs == null || !_isSameDay(lastTs.toDate(), now)) {
//         dailyCount = 0;
//       }

//       if (dailyCount >= 10) {
//         Get.snackbar(
//           'Daily limit reached',
//           'You can only post 2 updates per day.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.black87,
//           colorText: Colors.white,
//         );
//         return;
//       }

//       String? imageUrl;
//       String? audioUrl;

//       if (selectedImageBytes.value != null) {
//         imageUrl = await _uploadStatusImage(
//           selectedImageBytes.value!,
//           user.uid,
//         );
//       }

//       if (recordedAudioBytes.value != null) {
//         audioUrl = await uploadVoice(recordedAudioBytes.value!, user.uid);
//       }

//       final tempData = {
//         'text': text.trim(),
//         'name': userName,
//         'email': userEmail,
//         'imageUrl': imageUrl,
//         'audioUrl': audioUrl,
//         'likes': <String>[],
//         'timestamp': Timestamp.now(),
//       };

//       final statusRef = await _firestore.collection('status1').add(tempData);

//       selectedImageBytes.value = null;
//       removeRecordedVoice();

//       await userRef.update({
//         'lastStatusPostAt': FieldValue.serverTimestamp(),
//         'dailyPostCount': dailyCount + 1,
//       });

//       lastStatusPostAt.value = now;

//       await handleStatusPostr(statusRef.id, user.uid);
//     } catch (e) {
//       if (kDebugMode) print('❌ Post status error: $e');
//     } finally {
//       isPosting.value = false;
//     }
//   }

//   Future<void> toggleLike(DocumentSnapshot doc) async {
//     try {
//       final user = _auth.currentUser;

//       if (user == null) return;

//       final userUid = user.uid;

//       final currentList = List<DocumentSnapshot>.from(statuses);

//       final index = currentList.indexWhere((d) => d.id == doc.id);

//       if (index != -1) {
//         final currentData = currentList[index].data() as Map<String, dynamic>;

//         final likes = List<String>.from(currentData['likes'] ?? []);

//         bool liked = false;

//         if (likes.contains(userUid)) {
//           likes.remove(userUid);
//         } else {
//           likes.add(userUid);
//           liked = true;
//         }

//         /// ✅ INSTANT UI UPDATE
//         currentData['likes'] = likes;

//         statuses[index] = FakeDocumentSnapshot(
//           id: doc.id,
//           dataMap: currentData,
//         );

//         final docRef = _firestore.collection('status1').doc(doc.id);

//         await docRef.update({'likes': likes});

//         if (liked) {
//           await handleStatusLiker(statusId: doc.id, userUid: userUid);

//           final ownerEmail = currentData['email'] as String?;

//           if (ownerEmail != null && ownerEmail != user.email) {
//             final ownerQuery = await _firestore
//                 .collection('e-users')
//                 .where('email', isEqualTo: ownerEmail)
//                 .limit(1)
//                 .get();

//             if (ownerQuery.docs.isNotEmpty) {
//               final ownerUid = ownerQuery.docs.first.id;

//               await handleStatusOwnerr(
//                 statusId: doc.id,
//                 ownerUid: ownerUid,
//                 interactingUserUid: userUid,
//               );
//             }
//           }
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) print('❌ Toggle like error: $e');
//     }
//   }

//   void copyStatus(String text) {
//     Clipboard.setData(ClipboardData(text: text));

//     final ThemeController themeCtrl = Get.find<ThemeController>();

//     final bool isDark = themeCtrl.isDarkMode.value;

//     Get.snackbar(
//       '',
//       '',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//       margin: const EdgeInsets.all(12),
//       borderRadius: 12,
//       boxShadows: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.15),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//       titleText: Text(
//         'Copied',
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: isDark ? Colors.white : Colors.black,
//         ),
//       ),
//       messageText: Text(
//         'Status copied to clipboard',
//         style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87),
//       ),
//       duration: const Duration(seconds: 2),
//     );
//   }

//   List<DocumentSnapshot> get filteredStatuses {
//     final query = searchQuery.value.toLowerCase();

//     List<DocumentSnapshot> list = statuses.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;

//       final name = (data['name'] ?? '').toString().toLowerCase();

//       return query.isEmpty || name.contains(query);
//     }).toList();

//     list.sort((a, b) {
//       final aData = a.data() as Map<String, dynamic>;
//       final bData = b.data() as Map<String, dynamic>;

//       final aTs =
//           (aData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);

//       final bTs =
//           (bData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);

//       final aDay = DateTime(aTs.year, aTs.month, aTs.day);

//       final bDay = DateTime(bTs.year, bTs.month, bTs.day);

//       final dayCompare = bDay.compareTo(aDay);

//       if (dayCompare != 0) return dayCompare;

//       int rankFor(Map<String, dynamic> data) {
//         final name = (data['name'] ?? '').toString().trim().toLowerCase();

//         final email = data['email'] ?? '';

//         final isVerified = _verifiedCache[email] ?? false;

//         if (isVerified) return 0;

//         if (name.isEmpty || name == 'unknown' || name == 'anonymous user') {
//           return 2;
//         }

//         return 1;
//       }

//       final rankCompare = rankFor(aData).compareTo(rankFor(bData));

//       if (rankCompare != 0) return rankCompare;

//       return bTs.compareTo(aTs);
//     });

//     return list;
//   }

//   /// ✅ FAST REAL-TIME COMMENT STREAM
//   Stream<QuerySnapshot> commentStream(String statusId) {
//     return _firestore
//         .collection('status1')
//         .doc(statusId)
//         .collection('comments1')
//         .orderBy('timestamp', descending: false)
//         /// ✅ WEB CACHE SUPPORT
//         .snapshots(includeMetadataChanges: true);
//   }

//   /// ✅ LIVE COMMENT COUNT
//   final RxMap<String, int> commentCounts = <String, int>{}.obs;

//   final Map<String, StreamSubscription<QuerySnapshot>> _commentCountSubs = {};

//   /// ✅ PRELOAD COMMENT COUNTS FAST
//   void preloadCommentCounts() {
//     for (final doc in statuses) {
//       final statusId = doc.id;

//       // Avoid stacking duplicate listeners on every reload.
//       if (_commentCountSubs.containsKey(statusId)) continue;

//       _commentCountSubs[statusId] = _firestore
//           .collection('status1')
//           .doc(statusId)
//           .collection('comments1')
//           .snapshots()
//           .listen((snapshot) {
//             commentCounts[statusId] = snapshot.docs.length;
//           });
//     }
//   }

//   Future<void> postComment({
//     required String statusId,
//     required String text,
//   }) async {
//     if (text.trim().isEmpty) return;

//     try {
//       final user = _auth.currentUser;

//       if (user == null) return;

//       final now = DateTime.now();

//       final querySnapshot = await _firestore
//           .collection('status1')
//           .doc(statusId)
//           .collection('comments1')
//           .where('email', isEqualTo: user.email ?? '')
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final lastCommentTs =
//             (querySnapshot.docs.first['timestamp'] as Timestamp?)?.toDate();

//         if (lastCommentTs != null && _isSameDay(lastCommentTs, now)) {
//           Get.snackbar(
//             'Daily limit reached',
//             'You can only comment once per day on this status.',
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.black87,
//             colorText: Colors.white,
//           );

//           return;
//         }
//       }

//       final accountCtrl = Get.find<AccountController>();

//       final commenterName = accountCtrl.userName.value.isNotEmpty
//           ? accountCtrl.userName.value
//           : 'Anonymous';

//       /// ✅ INSTANT COMMENT COUNT UPDATE
//       commentCounts[statusId] = (commentCounts[statusId] ?? 0) + 1;

//       final commentRef = await _firestore
//           .collection('status1')
//           .doc(statusId)
//           .collection('comments1')
//           .add({
//             'text': text.trim(),
//             'name': commenterName,
//             'email': user.email ?? '',
//             'timestamp': FieldValue.serverTimestamp(),
//           });

//       await handleCommentr(commentId: commentRef.id, userUid: user.uid);

//       // 🔧 FIX: was reading from 'status' — the posts collection is
//       // actually 'status1', so this lookup was always failing silently
//       // and status-owner rs for comments never fired.
//       final postDoc = await _firestore
//           .collection('status1')
//           .doc(statusId)
//           .get();

//       final ownerEmail = postDoc.data()?['email'] as String?;

//       if (ownerEmail != null && ownerEmail != user.email) {
//         final ownerQuery = await _firestore
//             .collection('e-users')
//             .where('email', isEqualTo: ownerEmail)
//             .limit(1)
//             .get();

//         if (ownerQuery.docs.isNotEmpty) {
//           final ownerUid = ownerQuery.docs.first.id;

//           await handleStatusOwnerr(
//             statusId: statusId,
//             ownerUid: ownerUid,
//             interactingUserUid: user.uid,
//           );
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) print('❌ Post comment error: $e');
//     }
//   }

//   String formatPostTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';

//     final DateTime postTime = timestamp.toDate();

//     final DateTime now = DateTime.now();

//     final Duration diff = now.difference(postTime);

//     if (diff.inSeconds < 60) {
//       return 'Just now';
//     } else if (diff.inMinutes < 60) {
//       return '${diff.inMinutes}m ago';
//     } else if (diff.inHours < 24) {
//       return '${diff.inHours}h ago';
//     } else if (diff.inDays == 1) {
//       return 'Yesterday';
//     } else if (diff.inDays < 7) {
//       return '${diff.inDays}d ago';
//     } else {
//       final weeks = (diff.inDays / 7).floor();

//       return '${weeks}w ago';
//     }
//   }

//   Future<String?> fetchStatusUserAvatarName(String email) async {
//     try {
//       final query = await _firestore
//           .collection('e-users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get(const GetOptions(source: Source.serverAndCache));

//       if (query.docs.isEmpty) return null;

//       final userData = query.docs.first.data();

//       final avatarName = userData['avatar'] as String?;

//       return (avatarName != null && avatarName.isNotEmpty) ? avatarName : null;
//     } catch (e) {
//       if (kDebugMode) print('Error fetching avatar for $email: $e');
//       return null;
//     }
//   }

//   bool _isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   Future<void> handleStatusPostr(String statusId, String uid) async {
//     try {
//       final user = _auth.currentUser;

//       if (user == null) return;

//       final rRef = _firestore
//           .collection('statusrs')
//           .doc(user.uid)
//           .collection('statusPosts')
//           .doc(statusId);

//       if (!(await rRef.get()).exists) {
//         await _rCtrl.incrementTinyr(uid: user.uid);

//         await rRef.set({'red': true});
//       }
//     } catch (e) {
//       if (kDebugMode) print("❌ Error ring status post: $e");
//     }
//   }

//   Future<void> handleStatusLiker({
//     required String statusId,
//     required String userUid,
//   }) async {
//     try {
//       final rRef = _firestore
//           .collection('statusrs')
//           .doc(userUid)
//           .collection('statusLikes')
//           .doc(statusId);

//       if (!(await rRef.get()).exists) {
//         await _rCtrl.incrementTinyr(uid: userUid);

//         await rRef.set({'red': true});
//       }
//     } catch (e) {
//       if (kDebugMode) print("❌ Error ring status like: $e");
//     }
//   }

//   Future<void> handleCommentr({
//     required String commentId,
//     required String userUid,
//   }) async {
//     try {
//       final rRef = _firestore
//           .collection('statusrs')
//           .doc(userUid)
//           .collection('comments')
//           .doc(commentId);

//       if (!(await rRef.get()).exists) {
//         await _rCtrl.incrementTinyr(uid: userUid);

//         await rRef.set({'red': true});
//       }
//     } catch (e) {
//       if (kDebugMode) print("❌ Error ring comment: $e");
//     }
//   }

//   Future<void> handleStatusOwnerr({
//     required String statusId,
//     required String ownerUid,
//     required String interactingUserUid,
//   }) async {
//     try {
//       if (ownerUid == interactingUserUid) {
//         return;
//       }

//       final rRef = _firestore
//           .collection('statusrs')
//           .doc(ownerUid)
//           .collection('statusOwnerrs')
//           .doc('$statusId-$interactingUserUid');

//       if (!(await rRef.get()).exists) {
//         await _rCtrl.incrementTinyr(uid: ownerUid);

//         await rRef.set({
//           'red': true,
//           'byUser': interactingUserUid,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) print("❌ Error ring status owner: $e");
//     }
//   }

//   Future<bool> isUserVerifiedByEmail(String email) async {
//     try {
//       final query = await _firestore
//           .collection('e-users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get(const GetOptions(source: Source.serverAndCache));

//       if (query.docs.isEmpty) return false;

//       return query.docs.first.data()['verified'] == true;
//     } catch (e) {
//       if (kDebugMode) print('❌ Error checking verification: $e');

//       return false;
//     }
//   }

//   Future<bool> fetchUserVerifiedStatus(String email) async {
//     try {
//       final query = await _firestore
//           .collection('e-users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get(const GetOptions(source: Source.serverAndCache));

//       if (query.docs.isEmpty) return false;

//       return query.docs.first.data()['verified'] == true;
//     } catch (e) {
//       if (kDebugMode) {
//         print("❌ Error fetching verified status for $email: $e");
//       }

//       return false;
//     }
//   }

//   Future<bool> getVerifiedStatus(String email) async {
//     if (_verifiedCache.containsKey(email)) {
//       return _verifiedCache[email]!;
//     }

//     final verified = await fetchUserVerifiedStatus(email);

//     _verifiedCache[email] = verified;

//     return verified;
//   }

//   List<DocumentSnapshot> get paginatedStatuses {
//     final list = filteredStatuses;

//     final end = visibleCount.value > list.length
//         ? list.length
//         : visibleCount.value;

//     return list.take(end).toList();
//   }
// }

// // ignore: subtype_of_sealed_class
// /// ✅ HELPER CLASS FOR OPTIMISTIC UI
// class FakeDocumentSnapshot implements DocumentSnapshot {
//   @override
//   final String id;

//   final Map<String, dynamic> dataMap;

//   FakeDocumentSnapshot({required this.id, required this.dataMap});

//   @override
//   dynamic operator [](Object field) => dataMap[field];

//   @override
//   Map<String, dynamic>? data() => dataMap;

//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:homeo/controllers/account_controller.dart';
import 'package:homeo/controllers/e_login_controller.dart';
import 'package:homeo/controllers/moderation_controller.dart';
import 'package:homeo/controllers/r_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class StatusController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();
  final RController _rCtrl = Get.find<RController>();
  ModerationController get _moderation => Get.find<ModerationController>();

  /// ✅ CACHE
  final RxMap<String, String?> _avatarCache = <String, String?>{}.obs;
  final RxMap<String, bool> _verifiedCache = <String, bool>{}.obs;

  /// ✅ UI
  final RxString searchQuery = ''.obs;
  final RxList<DocumentSnapshot> statuses = <DocumentSnapshot>[].obs;
  final Rx<DateTime?> lastStatusPostAt = Rx<DateTime?>(null);

  /// ✅ IMAGE
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final ImagePicker _picker = ImagePicker();

  /// ✅ PAGINATION
  final RxInt visibleCount = 8.obs;
  final RxBool isLoadingMore = false.obs;
  final int maxLimit = 300;

  /// ✅ SMART LOADING
  final RxBool isInitialLoading = true.obs;

  StreamSubscription<QuerySnapshot>? _statusSubscription;

  final RxBool isPosting = false.obs;
  final RxBool isPostingComment = false.obs;
  final RxBool isSending = false.obs;

  @override
  void onInit() {
    super.onInit();

    /// ✅ LOAD IMMEDIATELY
    _listenToStatuses();

    /// ✅ LOAD LAST POST DATE
    _loadLastPostDate();
  }

  @override
  void onClose() {
    _statusSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;

    if (visibleCount.value >= filteredStatuses.length) return;

    isLoadingMore.value = true;

    await Future.delayed(const Duration(milliseconds: 200));

    visibleCount.value += 10;

    if (visibleCount.value > maxLimit) {
      visibleCount.value = maxLimit;
    }

    isLoadingMore.value = false;
  }

  /// 🚀 ULTRA FAST STATUS LOADER FOR WEB PRODUCTION
  void _listenToStatuses() {
    _statusSubscription?.cancel();

    _statusSubscription = _firestore
        .collection('status1')
        .orderBy('timestamp', descending: true)
        /// ✅ LIMIT FIRST LOAD
        .limit(maxLimit)
        /// ✅ INCLUDE CACHE FOR WEB SPEED
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            final docs = snapshot.docs;

            /// ✅ LOAD STATUSES IMMEDIATELY
            statuses.assignAll(docs);

            /// ✅ PRELOAD COMMENT COUNTS
            preloadCommentCounts();

            /// ✅ REMOVE LOADING IMMEDIATELY
            if (isInitialLoading.value) {
              isInitialLoading.value = false;
            }

            /// ✅ BACKGROUND CACHE LOADING
            _preloadUserData(docs);
          },
          onError: (e) {
            if (kDebugMode) print('❌ Status stream error: $e');

            isInitialLoading.value = false;
          },
        );
  }

  /// ✅ BACKGROUND PRELOAD
  Future<void> _preloadUserData(List<QueryDocumentSnapshot> docs) async {
    try {
      final Set<String> emails = {};

      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;

        final email = (data['email'] ?? '').toString();

        if (email.isNotEmpty) {
          emails.add(email);
        }
      }

      if (emails.isEmpty) return;

      /// ✅ FETCH IN PARALLEL
      await Future.wait(
        emails.map((email) async {
          try {
            /// VERIFIED
            if (!_verifiedCache.containsKey(email)) {
              final verified = await fetchUserVerifiedStatus(email);
              _verifiedCache[email] = verified;
            }

            /// AVATAR
            if (!_avatarCache.containsKey(email)) {
              final avatar = await fetchStatusUserAvatarName(email);
              _avatarCache[email] = avatar;
            }
          } catch (e) {
            if (kDebugMode) print('❌ Cache preload error for $email: $e');
          }
        }),
      );

      /// ✅ FORCE UI REFRESH
      statuses.refresh();
    } catch (e) {
      if (kDebugMode) print('❌ Background preload error: $e');
    }
  }

  String? getCachedAvatar(String email) {
    return _avatarCache[email];
  }

  bool getCachedVerified(String email) {
    return _verifiedCache[email] ?? false;
  }

  void _loadLastPostDate() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final doc = await _firestore
          .collection('e-users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.serverAndCache));

      final ts = doc.data()?['lastStatusPostAt'] as Timestamp?;

      lastStatusPostAt.value = ts?.toDate();
    } catch (e) {
      if (kDebugMode) print('❌ Error loading last post date: $e');
    }
  }

  Future<void> pickImageFromDevice() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,

        /// ✅ WEB OPTIMIZATION
        imageQuality: 75,
      );

      if (picked != null) {
        selectedImageBytes.value = await picked.readAsBytes();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Web image pick error: $e");
    }
  }

  Future<String?> _uploadStatusImage(Uint8List bytes, String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('status_images1')
          .child('${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      /// ✅ FAST WEB CACHE
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=31536000',
      );

      await ref.putData(bytes, metadata);

      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print("❌ Upload error: $e");
      return null;
    }
  }

  Future<void> postStatus(
    String text,
    String userName,
    String userEmail,
  ) async {
    if (text.trim().isEmpty && selectedImageBytes.value == null) {
      return;
    }

    // 🔧 FIX: guards against rapid double-taps firing two posts.
    if (isPosting.value) return;
    isPosting.value = true;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('e-users').doc(user.uid);
      final userSnap = await userRef.get();
      final data = userSnap.data() ?? {};

      final Timestamp? lastTs = data['lastStatusPostAt'];
      int dailyCount = data['dailyPostCount'] ?? 0;
      final now = DateTime.now();

      if (lastTs == null || !_isSameDay(lastTs.toDate(), now)) {
        dailyCount = 0;
      }

      if (dailyCount >= 3) {
        Get.snackbar(
          'Daily limit reached',
          'You can only post 3 updates per day.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return;
      }

      String? imageUrl;

      if (selectedImageBytes.value != null) {
        imageUrl = await _uploadStatusImage(
          selectedImageBytes.value!,
          user.uid,
        );
      }

      final tempData = {
        'text': text.trim(),
        'name': userName,
        'email': userEmail,
        'imageUrl': imageUrl,
        'likes': <String>[],
        'timestamp': Timestamp.now(),
      };

      final statusRef = await _firestore.collection('status1').add(tempData);

      selectedImageBytes.value = null;

      await userRef.update({
        'lastStatusPostAt': FieldValue.serverTimestamp(),
        'dailyPostCount': dailyCount + 1,
      });

      lastStatusPostAt.value = now;

      await handleStatusPostr(statusRef.id, user.uid);
    } catch (e) {
      if (kDebugMode) print('❌ Post status error: $e');
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> toggleLike(DocumentSnapshot doc) async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final userUid = user.uid;

      final currentList = List<DocumentSnapshot>.from(statuses);

      final index = currentList.indexWhere((d) => d.id == doc.id);

      if (index != -1) {
        final currentData = currentList[index].data() as Map<String, dynamic>;

        final likes = List<String>.from(currentData['likes'] ?? []);

        bool liked = false;

        if (likes.contains(userUid)) {
          likes.remove(userUid);
        } else {
          likes.add(userUid);
          liked = true;
        }

        /// ✅ INSTANT UI UPDATE
        currentData['likes'] = likes;

        statuses[index] = FakeDocumentSnapshot(
          id: doc.id,
          dataMap: currentData,
        );

        final docRef = _firestore.collection('status1').doc(doc.id);

        await docRef.update({'likes': likes});

        if (liked) {
          await handleStatusLiker(statusId: doc.id, userUid: userUid);

          final ownerEmail = currentData['email'] as String?;

          if (ownerEmail != null && ownerEmail != user.email) {
            final ownerQuery = await _firestore
                .collection('e-users')
                .where('email', isEqualTo: ownerEmail)
                .limit(1)
                .get();

            if (ownerQuery.docs.isNotEmpty) {
              final ownerUid = ownerQuery.docs.first.id;

              await handleStatusOwnerr(
                statusId: doc.id,
                ownerUid: ownerUid,
                interactingUserUid: userUid,
              );
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Toggle like error: $e');
    }
  }

  void copyStatus(String text) {
    Clipboard.setData(ClipboardData(text: text));

    final ThemeController themeCtrl = Get.find<ThemeController>();

    final bool isDark = themeCtrl.isDarkMode.value;

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      titleText: Text(
        'Copied',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      messageText: Text(
        'Status copied to clipboard',
        style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  List<DocumentSnapshot> get filteredStatuses {
    final query = searchQuery.value.toLowerCase();

    List<DocumentSnapshot> list = statuses.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final name = (data['name'] ?? '').toString().toLowerCase();

      return query.isEmpty || name.contains(query);
    }).toList();

    list.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aTs =
          (aData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);

      final bTs =
          (bData['timestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);

      final aDay = DateTime(aTs.year, aTs.month, aTs.day);

      final bDay = DateTime(bTs.year, bTs.month, bTs.day);

      final dayCompare = bDay.compareTo(aDay);

      if (dayCompare != 0) return dayCompare;

      int rankFor(Map<String, dynamic> data) {
        final name = (data['name'] ?? '').toString().trim().toLowerCase();

        final email = data['email'] ?? '';

        final isVerified = _verifiedCache[email] ?? false;

        if (isVerified) return 0;

        if (name.isEmpty || name == 'unknown' || name == 'anonymous user') {
          return 2;
        }

        return 1;
      }

      final rankCompare = rankFor(aData).compareTo(rankFor(bData));

      if (rankCompare != 0) return rankCompare;

      return bTs.compareTo(aTs);
    });

    return list;
  }

  /// ✅ FAST REAL-TIME COMMENT STREAM
  Stream<QuerySnapshot> commentStream(String statusId) {
    return _firestore
        .collection('status1')
        .doc(statusId)
        .collection('comments1')
        .orderBy('timestamp', descending: false)
        /// ✅ WEB CACHE SUPPORT
        .snapshots(includeMetadataChanges: true);
  }

  /// ✅ LIVE COMMENT COUNT
  final RxMap<String, int> commentCounts = <String, int>{}.obs;

  final Map<String, StreamSubscription<QuerySnapshot>> _commentCountSubs = {};

  /// ✅ PRELOAD COMMENT COUNTS FAST
  void preloadCommentCounts() {
    for (final doc in statuses) {
      final statusId = doc.id;

      // Avoid stacking duplicate listeners on every reload.
      if (_commentCountSubs.containsKey(statusId)) continue;

      _commentCountSubs[statusId] = _firestore
          .collection('status1')
          .doc(statusId)
          .collection('comments1')
          .snapshots()
          .listen((snapshot) {
            commentCounts[statusId] = snapshot.docs.length;
          });
    }
  }

  // Future<void> postComment({
  //   required String statusId,
  //   required String text,
  // }) async {
  //   if (text.trim().isEmpty) return;

  //   try {
  //     final user = _auth.currentUser;

  //     if (user == null) return;

  //     final now = DateTime.now();

  //     final querySnapshot = await _firestore
  //         .collection('status1')
  //         .doc(statusId)
  //         .collection('comments1')
  //         .where('email', isEqualTo: user.email ?? '')
  //         .orderBy('timestamp', descending: true)
  //         .limit(1)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       final lastCommentTs =
  //           (querySnapshot.docs.first['timestamp'] as Timestamp?)?.toDate();

  //       if (lastCommentTs != null && _isSameDay(lastCommentTs, now)) {
  //         Get.snackbar(
  //           'Daily limit reached',
  //           'You can only comment once per day on this status.',
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.black87,
  //           colorText: Colors.white,
  //         );

  //         return;
  //       }
  //     }

  //     final accountCtrl = Get.find<AccountController>();

  //     final commenterName = accountCtrl.userName.value.isNotEmpty
  //         ? accountCtrl.userName.value
  //         : 'Anonymous';

  //     /// ✅ INSTANT COMMENT COUNT UPDATE
  //     commentCounts[statusId] = (commentCounts[statusId] ?? 0) + 1;

  //     final commentRef = await _firestore
  //         .collection('status1')
  //         .doc(statusId)
  //         .collection('comments1')
  //         .add({
  //           'text': text.trim(),
  //           'name': commenterName,
  //           'email': user.email ?? '',
  //           'timestamp': FieldValue.serverTimestamp(),
  //         });

  //     await handleCommentr(commentId: commentRef.id, userUid: user.uid);

  //     // 🔧 FIX: was reading from 'status' — the posts collection is
  //     // actually 'status1', so this lookup was always failing silently
  //     // and status-owner rs for comments never fired.
  //     final postDoc = await _firestore
  //         .collection('status1')
  //         .doc(statusId)
  //         .get();

  //     final ownerEmail = postDoc.data()?['email'] as String?;

  //     if (ownerEmail != null && ownerEmail != user.email) {
  //       final ownerQuery = await _firestore
  //           .collection('e-users')
  //           .where('email', isEqualTo: ownerEmail)
  //           .limit(1)
  //           .get();

  //       if (ownerQuery.docs.isNotEmpty) {
  //         final ownerUid = ownerQuery.docs.first.id;

  //         await handleStatusOwnerr(
  //           statusId: statusId,
  //           ownerUid: ownerUid,
  //           interactingUserUid: user.uid,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('❌ Post comment error: $e');
  //   }
  // }

  /// 🔹 Post a comment
  ///
  /// Two checks run before a comment is saved:
  ///  1. Once-per-day-per-post — unchanged, same as before: a user can only
  ///     leave one comment on a given status per day.
  ///  2. Same-text-anywhere-today — new: whatever text a user comments with
  ///     today gets remembered for that day, and re-using that exact text on
  ///     *any other* post the same day is blocked until they write something
  ///     different. This is stored as a single small per-user, per-day
  ///     document (one read + one write) rather than scanning every post's
  ///     comments, to keep this light on reads/writes.
  Future<void> postComment({
    required String statusId,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    /// 🛑 HARD LOCK — same idea as ChatController.isSending, stops a
    /// double-tap from firing two comments while one is still in flight.
    if (isPostingComment.value) return;
    isPostingComment.value = true;

    try {
      final now = DateTime.now();
      final normalizedText = trimmedText.toLowerCase();
      final dateKey =
          '${now.year}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      // 1️⃣ Once-per-day-per-post check (as before)
      final querySnapshot = await _firestore
          .collection('status1')
          .doc(statusId)
          .collection('comments1')
          .where('email', isEqualTo: user.email ?? '')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastCommentTs =
            (querySnapshot.docs.first['timestamp'] as Timestamp?)?.toDate();
        if (lastCommentTs != null && _isSameDay(lastCommentTs, now)) {
          Get.snackbar(
            'Daily limit reached',
            'You can only comment once per day on this status.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );
          return;
        }
      }

      // 2️⃣ Same-comment-anywhere-today check
      final dailyRef = _firestore
          .collection('e-users')
          .doc(user.uid)
          .collection('dailyComments1')
          .doc(dateKey);

      final dailySnap = await dailyRef.get();
      final usedTexts = List<String>.from(
        dailySnap.data()?['texts'] ?? <String>[],
      );

      if (usedTexts.contains(normalizedText)) {
        Get.snackbar(
          'Same comment already used today',
          'You already posted that comment today. Try writing something different.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return;
      }

      // Post the comment
      final accountCtrl = Get.find<AccountController>();
      final commenterName = accountCtrl.userName.value.isNotEmpty
          ? accountCtrl.userName.value
          : 'Anonymous';

      final commentRef = await _firestore
          .collection('status1')
          .doc(statusId)
          .collection('comments1')
          .add({
            'text': trimmedText,
            'name': commenterName,
            'email': user.email ?? '',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 🔹 Remember this comment so it can't be repeated today, on any post
      await dailyRef.set({
        'texts': FieldValue.arrayUnion([normalizedText]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 🎁 r the user who commented
      await handleCommentr(commentId: commentRef.id, userUid: user.uid);

      // 🎁 r the owner of the post (skip if commenter is the owner)
      final postDoc = await _firestore
          .collection('status1')
          .doc(statusId)
          .get();
      final ownerEmail = postDoc['email'] as String?;
      if (ownerEmail != null && ownerEmail != user.email) {
        final ownerQuery = await _firestore
            .collection('e-users')
            .where('email', isEqualTo: ownerEmail)
            .limit(1)
            .get();
        if (ownerQuery.docs.isNotEmpty) {
          final ownerUid = ownerQuery.docs.first.id;
          await handleStatusOwnerr(
            statusId: statusId,
            ownerUid: ownerUid,
            interactingUserUid: user.uid, // <--- pass the commenter
          );
        }
      }
    } catch (e) {
      print("❌ Error posting comment: $e");
    } finally {
      /// 🔓 ALWAYS UNLOCK
      isPostingComment.value = false;
    }
  }

  String formatPostTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final DateTime postTime = timestamp.toDate();

    final DateTime now = DateTime.now();

    final Duration diff = now.difference(postTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      final weeks = (diff.inDays / 7).floor();

      return '${weeks}w ago';
    }
  }

  Future<String?> fetchStatusUserAvatarName(String email) async {
    try {
      final query = await _firestore
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get(const GetOptions(source: Source.serverAndCache));

      if (query.docs.isEmpty) return null;

      final userData = query.docs.first.data();

      final avatarName = userData['avatar'] as String?;

      return (avatarName != null && avatarName.isNotEmpty) ? avatarName : null;
    } catch (e) {
      if (kDebugMode) print('Error fetching avatar for $email: $e');
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> handleStatusPostr(String statusId, String uid) async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final rRef = _firestore
          .collection('statusrs')
          .doc(user.uid)
          .collection('statusPosts')
          .doc(statusId);

      if (!(await rRef.get()).exists) {
        await _rCtrl.incrementTinyr(uid: user.uid);

        await rRef.set({'red': true});
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error ring status post: $e");
    }
  }

  Future<void> handleStatusLiker({
    required String statusId,
    required String userUid,
  }) async {
    try {
      final rRef = _firestore
          .collection('statusrs')
          .doc(userUid)
          .collection('statusLikes')
          .doc(statusId);

      if (!(await rRef.get()).exists) {
        await _rCtrl.incrementTinyr(uid: userUid);

        await rRef.set({'red': true});
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error ring status like: $e");
    }
  }

  Future<void> handleCommentr({
    required String commentId,
    required String userUid,
  }) async {
    try {
      final rRef = _firestore
          .collection('statusrs')
          .doc(userUid)
          .collection('comments1')
          .doc(commentId);

      if (!(await rRef.get()).exists) {
        await _rCtrl.incrementTinyr(uid: userUid);

        await rRef.set({'red': true});
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error ring comment: $e");
    }
  }

  Future<void> handleStatusOwnerr({
    required String statusId,
    required String ownerUid,
    required String interactingUserUid,
  }) async {
    try {
      if (ownerUid == interactingUserUid) {
        return;
      }

      final rRef = _firestore
          .collection('statusrs')
          .doc(ownerUid)
          .collection('statusOwnerrs')
          .doc('$statusId-$interactingUserUid');

      if (!(await rRef.get()).exists) {
        await _rCtrl.incrementTinyr(uid: ownerUid);

        await rRef.set({
          'red': true,
          'byUser': interactingUserUid,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error ring status owner: $e");
    }
  }

  Future<bool> isUserVerifiedByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get(const GetOptions(source: Source.serverAndCache));

      if (query.docs.isEmpty) return false;

      return query.docs.first.data()['verified'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking verification: $e');

      return false;
    }
  }

  Future<bool> fetchUserVerifiedStatus(String email) async {
    try {
      final query = await _firestore
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get(const GetOptions(source: Source.serverAndCache));

      if (query.docs.isEmpty) return false;

      return query.docs.first.data()['verified'] == true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching verified status for $email: $e");
      }

      return false;
    }
  }

  Future<bool> getVerifiedStatus(String email) async {
    if (_verifiedCache.containsKey(email)) {
      return _verifiedCache[email]!;
    }

    final verified = await fetchUserVerifiedStatus(email);

    _verifiedCache[email] = verified;

    return verified;
  }

  List<DocumentSnapshot> get paginatedStatuses {
    final list = filteredStatuses;

    final end = visibleCount.value > list.length
        ? list.length
        : visibleCount.value;

    return list.take(end).toList();
  }

  Future<void> flagPostAction({
    required DocumentSnapshot doc,
    required String postText,
    required String postEmail,
    required String postName,
    required String reason,
  }) async {
    final data = doc.data() as Map<String, dynamic>;
    await _moderation.flagPost(
      postId: doc.id,
      postText: postText,
      postImageUrl: data['imageUrl'],
      postOwnerEmail: postEmail,
      postOwnerName: postName,
      reason: reason,
    );
  }
}

// ignore: subtype_of_sealed_class
/// ✅ HELPER CLASS FOR OPTIMISTIC UI
class FakeDocumentSnapshot implements DocumentSnapshot {
  @override
  final String id;

  final Map<String, dynamic> dataMap;

  FakeDocumentSnapshot({required this.id, required this.dataMap});

  @override
  dynamic operator [](Object field) => dataMap[field];

  @override
  Map<String, dynamic>? data() => dataMap;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
