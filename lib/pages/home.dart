import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeo/pages/logout_dialog.dart';
import 'package:homeo/pages/profile.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homeo/controllers/service_controller.dart';
import 'package:homeo/controllers/theme_controller.dart';
import 'package:homeo/pages/admin_login_page.dart';
import 'package:homeo/pages/service_details_page.dart';
import 'package:homeo/widgets/auth_required_dialog.dart';

/// Brand accent. Swap for the exact HOMEo brand color once you have it —
/// this is a deep, trustworthy teal chosen to feel premium and calm
/// rather than "marketplace-bright."
const Color kHomeoPrimary = Color(0xFF0E7C66);
const Color kHomeoPrimaryDark = Color(0xFF0A5C4C);

/// 🔹 "Admin Login" shows in the menu only while the admin account is
/// signed in. Uses the same [kHomeoAdminEmail] the admin gate itself
/// enforces (admin_login_page.dart), so the two can never drift apart.
bool get _isAdminSignedIn {
  final email = FirebaseAuth.instance.currentUser?.email?.toLowerCase().trim();
  return email != null && email == kHomeoAdminEmail.toLowerCase().trim();
}

bool get _isSignedIn => FirebaseAuth.instance.currentUser != null;

/// 🔹 Premium HOMEo service catalogue — the new Home tab.
///
/// Keeps the same constructor shape as the app's existing `Home` widget
/// (`userName`, `userEmail`) so it can be swapped in wherever `Home(...)`
/// is currently instantiated in the navigation shell.
class Home extends StatefulWidget {
  final String userName;
  final String userEmail;

  const Home({super.key, required this.userName, required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  final ServiceController serviceCtrl = Get.put(ServiceController());
  final ThemeController themeCtrl = Get.find<ThemeController>();

  // 🔹 Local, client-side service search — no extra Firestore query needed
  // since `serviceCtrl.services` is already the full active-services list.
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // 🔹 "There's more below" scroll hint — tracks the card list's own
  // scroll position so the hint fades out once the user reaches the end.
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreToScroll = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollHint);
    // Check right after the first layout too — a short list may not
    // need scrolling at all, so the hint should never show for it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  // 🔹 Recomputes whether there's unseen content below the fold. Called
  // on every scroll tick, and also scheduled after each build (see
  // build() below) since the list's length/height can change — e.g. a
  // search filtering results — without the user scrolling at all.
  void _updateScrollHint() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final hasMore =
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - 8;
    if (hasMore != _hasMoreToScroll) {
      setState(() => _hasMoreToScroll = hasMore);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      final bg = isDark ? Colors.black : const Color(0xFFF7F8F7);

      final query = _searchQuery.trim().toLowerCase();
      final filteredServices = query.isEmpty
          ? serviceCtrl.services
          : serviceCtrl.services
                .where((s) => s.name.toLowerCase().contains(query))
                .toList();

      // The list's length/height can change on this rebuild alone —
      // search filtering, Firestore data finishing load — without a
      // scroll event ever firing, so recheck once this frame settles.
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 🔹 Static — the logo/name row and overflow menu never
              // move, regardless of how the service list is scrolled.
              _Header(
                isDark: isDark,
                onProfileTap: _openProfile,
                onAdminTap: () => Get.to(
                  () => const AdminLoginPage(),
                  transition: Transition.cupertino,
                ),
                onSupportTap: _openSupportWhatsApp,
                onPolicyTap: _openPolicy,
                onTermsTap: _openTerms,
                onAboutTap: _openAbout,
                onToggleTheme: () =>
                    themeCtrl.isDarkMode.value = !themeCtrl.isDarkMode.value,
                onLogoutTap: _handleLogout,
              ),
              // 🔹 Static — "Home Services" title / search field stays
              // pinned above the list rather than scrolling away with it.
              _buildSectionHeader(isDark),
              // 🔹 Only this region scrolls. A premium "more below" hint
              // (fade + bouncing chevron) floats over the bottom edge
              // until the user actually reaches the end of the list.
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      color: kHomeoPrimary,
                      onRefresh: () async => serviceCtrl.loadServices(),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          _buildBody(isDark, filteredServices),
                          // Clearance so the last card never sits under
                          // the floating footer pill docked in
                          // bottomNavigationBar.
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ScrollFadeOverlay(
                        bg: bg,
                        visible: _hasMoreToScroll,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Center(
                        child: _ScrollMoreHint(
                          isDark: isDark,
                          visible: _hasMoreToScroll,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 🔹 Floating "Powered By" credit — pinned outside the scroll
        // view via Scaffold's own bottom slot, so it never moves as the
        // service list scrolls, without looking like a literal tab bar.
        bottomNavigationBar: _FloatingFooterBar(isDark: isDark),
      );
    });
  }

  // 🔹 "Home Services" title that swaps for a live search field when the
  // search icon is tapped. Typing filters the list below in real time;
  // clearing the field back to empty closes the search and restores the
  // title automatically.
  Widget _buildSectionHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _isSearching
                  ? TextField(
                      key: const ValueKey('search-field'),
                      controller: _searchController,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF14171A),
                      ),
                      cursorColor: kHomeoPrimary,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Search services…',
                        hintStyle: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        // The user backspaced all the way to empty —
                        // treat that as "cancel search" and revert.
                        if (value.isEmpty) {
                          FocusScope.of(context).unfocus();
                          setState(() => _isSearching = false);
                        }
                      },
                    )
                  : Text(
                      'Home Services',
                      key: const ValueKey('section-title'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF14171A),
                      ),
                    ),
            ),
          ),
          //const SizedBox(width: 10),
          Spacer(),
          _SearchToggleButton(
            isDark: isDark,
            isSearching: _isSearching,
            onPressed: () {
              if (_isSearching) {
                FocusScope.of(context).unfocus();
                _searchController.clear();
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              } else {
                setState(() => _isSearching = true);
              }
            },
          ),
        ],
      ),
    );
  }

  //https://docs.google.com/document/d/e/2PACX-1vRks9y9QrQsb3WbBtiepgXPDfEDA68T59liNfQvoyKXhz87oKRplLrkt0K2aQLIrqX51kGViqh6bv9h/pub

  // 🔹 Placeholder until HOMEo ships a dedicated profile screen — swap
  // this out for `Get.to(() => const ProfileScreen())` once it exists.
  // void _openProfile() {
  //   Get.snackbar(
  //     'Coming soon',
  //     'Your HOMEo profile page is on the way.',
  //     snackPosition: SnackPosition.BOTTOM,
  //   );
  // }

  // 🔹 Opens WhatsApp directly to HOMEo's support number, bypassing
  // whatever number ContactConfigController is otherwise configured
  // with, so this always goes to this fixed line.
  Future<void> _openSupportWhatsApp() async {
    const phoneNumber = '2349030323601'; // HOMEo general support
    final message = Uri.encodeComponent(
      'Hi HOMEo, I need help with General Support.',
    );
    final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _openTerms() async {
    final Uri url = Uri.parse(
      'https://docs.google.com/document/d/e/2PACX-1vRks9y9QrQsb3WbBtiepgXPDfEDA68T59liNfQvoyKXhz87oKRplLrkt0K2aQLIrqX51kGViqh6bv9h/pub',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not open the policy page',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // privacy policy / terms link.
  Future<void> _openPolicy() async {
    final Uri url = Uri.parse(
      'https://docs.google.com/document/d/e/2PACX-1vTjEQ4RoD_qTX52Bj819MRlaxNPmEfgcq5NVcW_HUbb3AvjVfSdlGKQOFlA_ZVuqLWDpH5r7PbnC74V/pub',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not open the policy page',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // privacy policy / terms link.
  Future<void> _openAbout() async {
    final Uri url = Uri.parse(
      'https://docs.google.com/document/d/e/2PACX-1vTeKINNAAPhmdOngq5-bQIKd7gtd0Fo7fgzGjuLaVRmsKbJewXlZiuKylE5QwXdl7ZA2iBCnPsnD7Nj/pub',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not open the about page',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 🔹 Profile needs an account — signed-out users get the same
  // "Sign in to continue" dialog the like button uses, no navigation.
  void _openProfile() {
    requireAuth(
      context,
      title: 'Sign in to continue',
      message: 'Please sign in to view and manage your HOMEo profile.',
      onAuthenticated: () =>
          Get.to(() => const ProfileScreen(), transition: Transition.cupertino),
    );
  }

  // 🔹 Premium confirm -> premium loader -> sign out. Stays on Home.
  Future<void> _handleLogout() => showLogoutFlow();

  Widget _buildBody(bool isDark, List<HomeoServiceModel> filteredServices) {
    if (serviceCtrl.isLoading.value) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _SkeletonCard(isDark: isDark),
            childCount: 4,
          ),
        ),
      );
    }

    if (serviceCtrl.loadError.value.isNotEmpty) {
      return SliverToBoxAdapter(
        child: _ErrorState(
          isDark: isDark,
          message: serviceCtrl.loadError.value,
          onRetry: serviceCtrl.loadServices,
        ),
      );
    }

    if (serviceCtrl.services.isEmpty) {
      return SliverToBoxAdapter(child: _EmptyState(isDark: isDark));
    }

    if (filteredServices.isEmpty) {
      return SliverToBoxAdapter(
        child: _NoSearchResultsState(
          isDark: isDark,
          query: _searchQuery.trim(),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
          final service = filteredServices[i];
          return _ServiceCard(service: service, isDark: isDark);
        }, childCount: filteredServices.length),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final VoidCallback onProfileTap;
  final VoidCallback onAdminTap;
  final VoidCallback onSupportTap;
  final VoidCallback onPolicyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onAboutTap;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogoutTap;

  const _Header({
    required this.isDark,
    required this.onProfileTap,
    required this.onAdminTap,
    required this.onSupportTap,
    required this.onPolicyTap,
    required this.onTermsTap,
    required this.onAboutTap,
    required this.onToggleTheme,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.asset('assets/images/HOMEo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOMEo',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: isDark ? Colors.white : const Color(0xFF14171A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Home Services, Simplified.',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // 🔹 Single overflow entry point — replaces the standalone admin
          // icon and surfaces Profile, Admin Login, Support, Policy, the
          // theme toggle and Logout from one compact three-dot button.
          _HeaderMenuButton(
            isDark: isDark,
            onProfileTap: onProfileTap,
            onAdminTap: onAdminTap,
            onSupportTap: onSupportTap,
            onPolicyTap: onPolicyTap,
            onTermsTap: onTermsTap,
            onAboutTap: onAboutTap,
            onToggleTheme: onToggleTheme,
            onLogoutTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

/// 🔹 Premium three-dot dropdown menu for the home header.
class _HeaderMenuButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onProfileTap;
  final VoidCallback onAdminTap;
  final VoidCallback onSupportTap;
  final VoidCallback onPolicyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onAboutTap;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogoutTap;

  const _HeaderMenuButton({
    required this.isDark,
    required this.onProfileTap,
    required this.onAdminTap,
    required this.onSupportTap,
    required this.onPolicyTap,
    required this.onTermsTap,
    required this.onAboutTap,
    required this.onToggleTheme,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<String>(
        tooltip: 'Menu',
        color: isDark ? const Color(0xFF1C1F24) : Colors.white,
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        offset: const Offset(0, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        icon: Icon(
          Icons.more_vert_rounded,
          color: isDark ? Colors.white70 : kHomeoPrimary,
        ),
        onSelected: (value) {
          switch (value) {
            case 'profile':
              onProfileTap();
              break;
            case 'admin':
              onAdminTap();
              break;
            case 'support':
              onSupportTap();
              break;
            case 'policy':
              onPolicyTap();
              break;
            case 'terms':
              onTermsTap();
              break;
            case 'about':
              onAboutTap();
              break;
            case 'theme':
              onToggleTheme();
              break;
            case 'logout':
              onLogoutTap();
              break;
          }
        },
        itemBuilder: (context) => [
          _item(
            value: 'profile',
            icon: Icons.person_outline_rounded,
            label: 'Profile',
          ),
          if (_isAdminSignedIn)
            _item(
              value: 'admin',
              icon: Icons.admin_panel_settings_rounded,
              label: 'Admin Login',
            ),
          const PopupMenuDivider(height: 12),
          _item(
            value: 'support',
            icon: Icons.support_agent_rounded,
            label: 'Support',
          ),
          _item(
            value: 'policy',
            icon: Icons.privacy_tip_outlined,
            label: 'Policy',
          ),
          _item(
            value: 'terms',
            icon: Icons.book_outlined,
            label: 'Terms of Service',
          ),
          _item(
            value: 'about',
            icon: Icons.info_outline_rounded,
            label: 'About Us',
          ),
          const PopupMenuDivider(height: 12),
          _item(
            value: 'theme',
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            label: isDark ? 'Light Mode' : 'Dark Mode',
            iconColor: isDark ? Colors.amber : null,
          ),
          if (_isSignedIn) ...[
            const PopupMenuDivider(height: 12),
            _item(
              value: 'logout',
              icon: Icons.logout_rounded,
              label: 'Logout',
              iconColor: Colors.redAccent,
              labelColor: Colors.redAccent,
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<String> _item({
    required String value,
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? labelColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: iconColor ?? (isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: labelColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Premium circular icon button that toggles the header between the
/// "Home Services" title and the live search field, swapping its own
/// icon (search ⇄ close) to match.
class _SearchToggleButton extends StatelessWidget {
  final bool isDark;
  final bool isSearching;
  final VoidCallback onPressed;

  const _SearchToggleButton({
    required this.isDark,
    required this.isSearching,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : kHomeoPrimary.withOpacity(0.08),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              key: ValueKey(isSearching),
              size: 19,
              color: isDark ? Colors.white70 : kHomeoPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔹 Shown when a search query matches none of the loaded services —
/// distinct from `_EmptyState`, which is for "no services at all".
class _NoSearchResultsState extends StatelessWidget {
  final bool isDark;
  final String query;

  const _NoSearchResultsState({required this.isDark, required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 14),
          Text(
            'No services match "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different name or clear the search.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final HomeoServiceModel service;
  final bool isDark;

  const _ServiceCard({required this.service, required this.isDark});

  static const double _kImageHeight = 168;
  static const double _kCardRadius = 22;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDark ? const Color(0xFF16191D) : Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_kCardRadius),
          onTap: () => Get.to(
            () => ServiceDetailsPage(serviceId: service.id),
            transition: Transition.cupertino,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_kCardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Full-width image banner, top-rounded to match the card
                // and cropped to fill the frame edge-to-edge (no letterboxing)
                // regardless of the underlying thumb's native aspect ratio.
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_kCardRadius),
                  ),
                  child: SizedBox(
                    height: _kImageHeight,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: ServiceThumb(
                          service: service,
                          size: 260,
                          radius: 0,
                          iconSize: 84,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF14171A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'View Service',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: kHomeoPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: kHomeoPrimary,
                          ),
                          const Spacer(),
                          Text(
                            '${service.likesCount} ${service.likesCount == 1 ? "like" : "likes"}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _LikeButton(service: service),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔹 Animated like/favorite button. Signed-out taps route through the
/// auth-required dialog and never touch Firestore.
class _LikeButton extends StatefulWidget {
  final HomeoServiceModel service;
  const _LikeButton({required this.service});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );

  final serviceCtrl = Get.find<ServiceController>();

  void _handleTap() {
    requireAuth(
      context,
      title: 'Sign in to continue',
      message:
          'Please sign in to like and save HOMEo services to your profile.',
      onAuthenticated: () {
        _controller
          ..value = 0.85
          ..animateTo(1.0, curve: Curves.elasticOut);
        serviceCtrl.toggleServiceLike(widget.service.id);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final liked = serviceCtrl.isLiked(widget.service.id);
      return GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _controller,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: liked ? const Color(0xFFE0507A) : Colors.grey,
              size: 22,
            ),
          ),
        ),
      );
    });
  }
}

class _SkeletonCard extends StatelessWidget {
  final bool isDark;
  const _SkeletonCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF1E2126) : const Color(0xFFEDEEF0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16191D) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 168, width: double.infinity, color: base),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 13, width: 120, color: base),
                  const SizedBox(height: 10),
                  Container(height: 11, width: double.infinity, color: base),
                  const SizedBox(height: 6),
                  Container(height: 11, width: 160, color: base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 44,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 14),
          Text(
            'No services available right now',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check back soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Premium floating footer credit — docked in Scaffold's
/// `bottomNavigationBar` slot so it stays fixed in place regardless of
/// how the service list above is scrolled. Styled as a slim rounded
/// "floating pill" (with its own shadow and safe-area padding) rather
/// than a full-width, edge-to-edge tab bar.
class _FloatingFooterBar extends StatelessWidget {
  final bool isDark;
  const _FloatingFooterBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16191D) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            'Powered By AFIA SPLENDID LTD',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔹 Soft gradient fade over the bottom edge of the scrollable service
/// list — a quiet, premium cue that more content sits below, matching
/// the page background so it reads as a fade rather than a hard edge.
class _ScrollFadeOverlay extends StatelessWidget {
  final Color bg;
  final bool visible;

  const _ScrollFadeOverlay({required this.bg, required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: visible ? 1 : 0,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [bg, bg.withOpacity(0)],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔹 Small floating "more below" badge — a gently bouncing chevron in a
/// frosted pill — that fades out once the user actually reaches the end
/// of the service list.
class _ScrollMoreHint extends StatefulWidget {
  final bool isDark;
  final bool visible;

  const _ScrollMoreHint({required this.isDark, required this.visible});

  @override
  State<_ScrollMoreHint> createState() => _ScrollMoreHintState();
}

class _ScrollMoreHintState extends State<_ScrollMoreHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _bounce = Tween<double>(
    begin: 0,
    end: 5,
  ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: widget.visible ? 1 : 0,
        child: AnimatedBuilder(
          animation: _bounce,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _bounce.value),
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.black.withOpacity(0.55)
                  : Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white10
                    : Colors.black.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.4 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: widget.isDark ? Colors.white70 : kHomeoPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.isDark,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.redAccent),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Try again',
              style: TextStyle(
                color: kHomeoPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
