import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:homeo/controllers/service_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/pages/home.dart' show kHomeoPrimary;

/// 🔹 Admin Services Management page.
///
/// Only reachable for users where `e-users/{uid}.isAdmin == true`
/// (`ServiceController.isAdmin`). Route to this page from wherever your
/// admin entry point lives; it self-gates and shows an access-denied
/// state for anyone else, so it's also safe if a non-admin somehow
/// lands here via a deep link.
class _AccessDeniedField extends StatelessWidget {
  final String label;
  final String value;

  const _AccessDeniedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 15),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            Get.snackbar(
              'Copied',
              '$label copied to clipboard.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      ],
    );
  }
}

void _showAdminActionError(Object error) {
  if (error is NotAdminException) {
    Get.snackbar(
      'Not an admin account',
      'This account isn\'t marked as an admin in Firestore yet '
          '(e-users/{uid}.isAdmin must be true).',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  } else {
    Get.snackbar(
      'Error',
      'That action could not be completed. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final serviceCtrl = Get.find<ServiceController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      if (!serviceCtrl.isAdmin.value) {
        final user = FirebaseAuth.instance.currentUser;
        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: AppBar(title: const Text('Admin')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 36,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'You do not have access to this page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 18),
                    Text(
                      'This account isn\'t marked as an admin in Firestore '
                      'yet. In the Firebase console, add isAdmin: true to '
                      'the document below, then tap "Try again" — no need '
                      'to sign out and back in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.04)
                            : const Color(0xFFF3F4F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AccessDeniedField(
                            label: 'Path',
                            value: 'e-users/${user.uid}',
                          ),
                          const SizedBox(height: 8),
                          _AccessDeniedField(
                            label: 'Email',
                            value: user.email ?? '(none)',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: serviceCtrl.refreshAdminStatus,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kHomeoPrimary,
                        side: const BorderSide(color: kHomeoPrimary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8F7),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Manage Services',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: kHomeoPrimary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Service',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => _openServiceEditor(context, isDark: isDark),
        ),
        body: serviceCtrl.isAdminLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: kHomeoPrimary),
              )
            : serviceCtrl.adminServices.isEmpty
            ? Center(
                child: Text(
                  'No services yet. Tap "Add Service" to create one.',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                itemCount: serviceCtrl.adminServices.length,
                onReorder: (oldIndex, newIndex) {
                  final list = List<HomeoServiceModel>.from(
                    serviceCtrl.adminServices,
                  );
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);
                  serviceCtrl
                      .reorderServices(list)
                      .catchError((e) => _showAdminActionError(e));
                },
                itemBuilder: (context, index) {
                  final service = serviceCtrl.adminServices[index];
                  return _AdminServiceTile(
                    key: ValueKey(service.id),
                    service: service,
                    isDark: isDark,
                    onEdit: () => _openServiceEditor(
                      context,
                      isDark: isDark,
                      existing: service,
                    ),
                  );
                },
              ),
      );
    });
  }

  void _openServiceEditor(
    BuildContext context, {
    required bool isDark,
    HomeoServiceModel? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServiceEditorSheet(isDark: isDark, existing: existing),
    );
  }
}

class _AdminServiceTile extends StatelessWidget {
  final HomeoServiceModel service;
  final bool isDark;
  final VoidCallback onEdit;

  const _AdminServiceTile({
    super.key,
    required this.service,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final serviceCtrl = Get.find<ServiceController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16191D) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: serviceCtrl.adminServices.indexOf(service),
            child: Icon(
              Icons.drag_indicator_rounded,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
          const SizedBox(width: 8),
          ServiceThumb(service: service, size: 44, radius: 13, iconSize: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${service.likesCount} likes',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: service.isActive,
            activeColor: kHomeoPrimary,
            onChanged: (v) => serviceCtrl
                .setServiceActive(service.id, v)
                .catchError((e) => _showAdminActionError(e)),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') _confirmDelete(context, service);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, HomeoServiceModel service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete service?'),
        content: Text(
          'This permanently removes "${service.name}". Consider disabling it instead if you might bring it back.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<ServiceController>()
                  .deleteService(service.id)
                  .catchError((e) => _showAdminActionError(e));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ServiceEditorSheet extends StatefulWidget {
  final bool isDark;
  final HomeoServiceModel? existing;

  const _ServiceEditorSheet({required this.isDark, this.existing});

  @override
  State<_ServiceEditorSheet> createState() => _ServiceEditorSheetState();
}

class _ServiceEditorSheetState extends State<_ServiceEditorSheet> {
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _descCtrl = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final TextEditingController _coverageCtrl = TextEditingController(
    text: widget.existing?.coverage ?? '',
  );
  late String _selectedIcon =
      widget.existing?.icon ?? kHomeoServiceIcons.keys.first;

  bool _saving = false;

  // 🔹 Cover photo state:
  // - _pickedBytes/_pickedName: a newly picked-but-not-yet-uploaded image.
  // - _existingImageUrl: the service's current photo, if editing one.
  // - _imageRemoved: user explicitly cleared the photo with no
  //   replacement picked — an empty imageUrl is sent to Firestore on save.
  Uint8List? _pickedBytes;
  String? _pickedName;
  bool _uploadingImage = false;
  late String _existingImageUrl = widget.existing?.imageUrl ?? '';
  bool _imageRemoved = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _coverageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pickedBytes = bytes;
      _pickedName = picked.name;
      _imageRemoved = false;
    });
  }

  void _clearImage() {
    setState(() {
      _pickedBytes = null;
      _pickedName = null;
      _imageRemoved = true;
    });
  }

  /// 🔹 Uploads the newly picked image (if any) to Firebase Storage under
  /// `service_images/` and returns its download URL. Returns null when
  /// there's nothing new to upload — the caller decides what that means
  /// (keep the existing photo, or clear it, based on [_imageRemoved]).
  Future<String?> _uploadPickedImage() async {
    if (_pickedBytes == null) return null;

    setState(() => _uploadingImage = true);
    try {
      final serviceId =
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final ext = (_pickedName != null && _pickedName!.contains('.'))
          ? _pickedName!.split('.').last
          : 'jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('service_images')
          .child('$serviceId.$ext');

      await ref.putData(
        _pickedBytes!,
        SettableMetadata(contentType: 'image/$ext'),
      );
      return await ref.getDownloadURL();
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Missing info',
        'Name and description are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _saving = true);
    final serviceCtrl = Get.find<ServiceController>();

    try {
      String? uploadedUrl;
      try {
        uploadedUrl = await _uploadPickedImage();
      } catch (e) {
        // Image upload failing shouldn't block saving the rest of the
        // service — fall back to whatever photo it already had.
        Get.snackbar(
          'Image upload failed',
          'Saved the service, but the photo could not be uploaded.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      if (widget.existing == null) {
        await serviceCtrl.addService(
          name: _nameCtrl.text,
          description: _descCtrl.text,
          coverage: _coverageCtrl.text,
          iconKey: _selectedIcon,
          imageUrl: uploadedUrl ?? '',
        );
      } else {
        // null = leave the existing photo untouched; '' = clear it.
        final imageUrlForUpdate = uploadedUrl ?? (_imageRemoved ? '' : null);
        await serviceCtrl.updateService(
          serviceId: widget.existing!.id,
          name: _nameCtrl.text,
          description: _descCtrl.text,
          coverage: _coverageCtrl.text,
          iconKey: _selectedIcon,
          imageUrl: imageUrlForUpdate,
        );
      }
      if (mounted) Get.back();
    } on NotAdminException {
      Get.snackbar(
        'Not an admin account',
        'This account isn\'t marked as an admin in Firestore yet '
            '(e-users/{uid}.isAdmin must be true). Ask another admin to '
            'enable it, then try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not save service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16191D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                isEditing ? 'Edit Service' : 'Add Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              _field('Name', _nameCtrl, isDark),
              const SizedBox(height: 12),
              _field('Short description', _descCtrl, isDark, maxLines: 2),
              const SizedBox(height: 12),
              _field(
                'What it covers (optional)',
                _coverageCtrl,
                isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Cover photo (optional)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              _buildImagePicker(isDark),
              const SizedBox(height: 16),
              Text(
                'Icon',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kHomeoServiceIcons.entries.map((entry) {
                  final selected = _selectedIcon == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: selected
                            ? kHomeoPrimary
                            : kHomeoPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        entry.value,
                        color: selected ? Colors.white : kHomeoPrimary,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kHomeoPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Add Service',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    final hasPicked = _pickedBytes != null;
    final hasExisting = !_imageRemoved && _existingImageUrl.trim().isNotEmpty;
    final hasAnyImage = hasPicked || hasExisting;

    Widget preview;
    if (hasPicked) {
      preview = Image.memory(_pickedBytes!, fit: BoxFit.cover);
    } else if (hasExisting) {
      preview = Image.network(
        _existingImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Icon(
          Icons.broken_image_rounded,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
      );
    } else {
      preview = Icon(
        Icons.add_photo_alternate_outlined,
        color: isDark ? Colors.white38 : Colors.black38,
        size: 28,
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _uploadingImage ? null : _pickImage,
          child: Container(
            width: 84,
            height: 84,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: _uploadingImage
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Center(child: preview),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: _uploadingImage ? null : _pickImage,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: kHomeoPrimary,
                ),
                label: Text(
                  hasAnyImage ? 'Change photo' : 'Choose photo',
                  style: const TextStyle(
                    color: kHomeoPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              if (hasAnyImage) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _uploadingImage ? null : _clearImage,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Remove photo',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  'Shown in the catalogue instead of the icon below.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFF3F4F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
