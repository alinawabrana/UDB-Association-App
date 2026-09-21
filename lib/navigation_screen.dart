import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/auth/provider/user_role_fallback_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  // final List<Widget> screens = [
  //   HomeScreen(),
  //   Container(color: Colors.redAccent),
  //   Container(color: Colors.blueAccent),
  //   Container(color: Colors.yellowAccent),
  // ];

  int currentIndex = 0;
  bool _isFooterExpanded = true;
  String? _lastRoute;
  ProviderSubscription<AsyncValue<bool>>? _subscriptionStatusSub;
  ProviderSubscription<String?>? _authTokenSub;

  @override
  void initState() {
    super.initState();
    _setCurrentIndexFromRoute();

    _subscriptionStatusSub = ref.listenManual(
      userHasApprovedSubscriptionProvider,
      (previous, next) {
        if (previous != next && mounted) {
          setState(() {
            currentIndex = 0;
          });
        }
      },
    );

    _authTokenSub = ref.listenManual(authTokenProvider, (previous, next) {
      if (previous != null && next == null && mounted) {
        setState(() {
          currentIndex = 0;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setCurrentIndexFromRoute();
  }

  @override
  void didUpdateWidget(NavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update index when widget updates (route changes)
    _setCurrentIndexFromRoute();
  }

  @override
  void dispose() {
    _subscriptionStatusSub?.close();
    _authTokenSub?.close();
    super.dispose();
  }

  void _setCurrentIndexFromRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).fullPath;
      final effectiveUserRole = ref.read(effectiveUserRoleProvider);
      final normalizedRole = effectiveUserRole?.toLowerCase();
      final subscriptionStatus = ref.read(userHasApprovedSubscriptionProvider);
      final l10n = context.l10n;

      if (normalizedRole == 'user' && subscriptionStatus.isLoading) {
        return;
      }

      if (_lastRoute == location &&
          !(normalizedRole == 'user' && subscriptionStatus.isLoading)) {
        return;
      }

      final tabs = _buildTabDefinitions(normalizedRole, l10n);

      final targetIndex = _indexForLocation(location, tabs);

      if (targetIndex != null && targetIndex != currentIndex && mounted) {
        setState(() {
          currentIndex = targetIndex;
        });
      }

      _lastRoute = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get effective user role (API first, then fallback)
    final effectiveUserRole = ref.watch(effectiveUserRoleProvider);
    final token = ref.watch(authTokenProvider);
    final hasApprovedSubscription = ref.watch(
      userHasApprovedSubscriptionProvider,
    );
    final normalizedRole = effectiveUserRole?.toLowerCase();
    final isSpecialDecisionPending =
        normalizedRole == 'user' && hasApprovedSubscription.isLoading;
    final l10n = context.l10n;

    // Debug prints (only when role changes to avoid spam)
    if (effectiveUserRole != null) {
      print('NavigationScreen - Token: $token');
      print('NavigationScreen - Effective user role: $effectiveUserRole');
    }

    // Build navigation items first to get the correct count
    final tabDefinitions = isSpecialDecisionPending
        ? <_TabDefinition>[]
        : _buildTabDefinitions(normalizedRole, l10n);

    // Ensure currentIndex is within bounds
    final tabCount = tabDefinitions.length;
    final safeCurrentIndex = tabCount == 0
        ? 0
        : (currentIndex >= tabDefinitions.length
              ? tabDefinitions.length - 1
              : currentIndex);

    // Update currentIndex if it was out of bounds
    if (tabDefinitions.isNotEmpty && currentIndex != safeCurrentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            currentIndex = safeCurrentIndex;
          });
        }
      });
    }

    final body = isSpecialDecisionPending
        ? const Center(child: CircularProgressIndicator())
        : widget.child;

    final mediaQuery = MediaQuery.of(context);
    final routeState = GoRouterState.of(context);
    final currentLocation = routeState.fullPath ?? routeState.uri.toString();
    final showFooter = !isSpecialDecisionPending && tabDefinitions.isNotEmpty;
    final bool isHomeContext = currentLocation.startsWith('/app_images');
    final bool allowFooterToggle = !isHomeContext;
    final bool effectiveExpanded = allowFooterToggle ? _isFooterExpanded : true;
    final footerHeight = showFooter
        ? _FooterNavigationSheet.heightFor(
            effectiveExpanded,
            mediaQuery.padding.bottom,
          )
        : 0.0;

    return Scaffold(
      backgroundColor: isHomeContext ? Colors.transparent : null,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: allowFooterToggle ? footerHeight : 0.0,
              ),
              child: body,
            ),
          ),
          if (showFooter)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _FooterNavigationSheet(
                tabs: tabDefinitions,
                currentIndex: safeCurrentIndex,
                isExpanded: effectiveExpanded,
                isHomeContext: isHomeContext,
                allowToggle: allowFooterToggle,
                onToggle: allowFooterToggle
                    ? () {
                        setState(() {
                          _isFooterExpanded = !_isFooterExpanded;
                        });
                      }
                    : null,
                onSelect: (index) {
                  if (index == safeCurrentIndex) {
                    return;
                  }
                  final didNavigate = _handleNavigation(
                    index,
                    normalizedRole,
                    hasApprovedSubscription,
                  );

                  if (didNavigate && mounted) {
                    setState(() {
                      currentIndex = index;
                    });
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _handleNavigation(
    int index,
    String? normalizedRole,
    AsyncValue<bool> hasApprovedSubscription,
  ) {
    if (normalizedRole == 'user' && hasApprovedSubscription.isLoading) {
      print(
        'NavigationScreen - Subscription status loading, ignoring navigation tap',
      );
      return false;
    }

    final isSpecialUser = _isSpecialUser(
      normalizedRole,
      hasApprovedSubscription,
    );
    final tabs = _buildTabDefinitions(normalizedRole, context.l10n);

    if (index < 0 || index >= tabs.length) {
      return false;
    }

    final tab = tabs[index];

    if (_shouldShowMembershipSnackbar(
      routeName: tab.routeName,
      normalizedRole: normalizedRole,
      isSpecialUser: isSpecialUser,
    )) {
      SnackbarUtils.showInfo(
        context,
        message: context.l10n.translate('footer_become_member_snackbar'),
      );
      return false;
    }

    context.goNamed(tab.routeName);
    return true;
  }

  bool _isSpecialUser(
    String? normalizedRole,
    AsyncValue<bool> subscriptionStatus,
  ) {
    if (normalizedRole != 'user') {
      return false;
    }
    return subscriptionStatus.when(
      data: (hasApproved) => hasApproved,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  bool _shouldShowMembershipSnackbar({
    required String routeName,
    required String? normalizedRole,
    required bool isSpecialUser,
  }) {
    final role = normalizedRole ?? '';
    final isVendor = role == 'vendor';
    final isMember = role == 'member';
    final isManager = role == 'manager';

    switch (routeName) {
      case AppRouteNames.appNews:
        final allowed = isManager || isMember || isVendor || isSpecialUser;
        return !allowed;
      case AppRouteNames.appEvents:
        final allowed = isManager || isMember;
        return !allowed;
      case AppRouteNames.appDirectory:
        final allowed = isManager || isMember || isVendor || isSpecialUser;
        return !allowed;
      default:
        return false;
    }
  }

  List<_TabDefinition> _buildTabDefinitions(
    String? normalizedRole,
    AppLocalizations l10n,
  ) {
    final isFrench = l10n.locale.languageCode.toLowerCase() == 'fr';
    final newsLabel = isFrench ? 'Infos' : l10n.translate('news');
    final eventsLabel = isFrench ? 'Agenda' : l10n.translate('events');
    final projectRoute = normalizedRole == 'manager'
        ? AppRouteNames.managerProjects
        : AppRouteNames.appProjects;
    final projectPrefixes = normalizedRole == 'manager'
        ? const ['/manager_projects']
        : const ['/app_projects'];

    return [
      _TabDefinition(
        icon: Icons.home_outlined,
        label: l10n.translate('home'),
        routeName: AppRouteNames.appImages,
        matchingPrefixes: const ['/app_images'],
      ),
      _TabDefinition(
        icon: Icons.article_outlined,
        label: newsLabel,
        routeName: AppRouteNames.appNews,
        matchingPrefixes: const ['/app_news', '/user_notifications'],
      ),
      _TabDefinition(
        icon: Icons.event_available_outlined,
        label: eventsLabel,
        routeName: AppRouteNames.appEvents,
        matchingPrefixes: const ['/app_events'],
      ),
      _companiesTabDefinition(l10n),
      _TabDefinition(
        icon: Icons.people_outline,
        label: l10n.translate('directory'),
        routeName: AppRouteNames.appDirectory,
        matchingPrefixes: const ['/app_directory'],
      ),
      _TabDefinition(
        icon: Icons.work_outline,
        label: l10n.translate('projects'),
        routeName: projectRoute,
        matchingPrefixes: projectPrefixes,
      ),
      _TabDefinition(
        icon: Icons.shopping_bag_outlined,
        label: l10n.translate('shop'),
        routeName: AppRouteNames.userProduct,
        matchingPrefixes: const [
          '/user_product',
          '/user_cart',
          '/user_product_detail',
          '/product_checkout',
          '/order_success',
        ],
      ),
      _profileTabDefinition(l10n),
    ];
  }

  _TabDefinition _profileTabDefinition(AppLocalizations l10n) {
    return _TabDefinition(
      icon: Icons.person_outline,
      label: l10n.translate('profile'),
      routeName: AppRouteNames.profile,
      matchingPrefixes: const [
        '/profile',
        '/profile/orders',
        '/profile/orders/order_detail',
        '/profile/subscription_selection',
        '/profile/subscription_selection/subscription_checkout',
      ],
    );
  }

  _TabDefinition _companiesTabDefinition(AppLocalizations l10n) {
    return _TabDefinition(
      icon: Icons.business_outlined,
      label: l10n.translate('organes_title'),
      routeName: AppRouteNames.allBranchesDetail,
      matchingPrefixes: const ['/all_branches_detail'],
    );
  }

  int? _indexForLocation(String? location, List<_TabDefinition> tabs) {
    if (tabs.isEmpty) {
      return null;
    }

    final path = location ?? '/app_images';

    for (var i = 0; i < tabs.length; i++) {
      for (final prefix in tabs[i].matchingPrefixes) {
        if (path.startsWith(prefix)) {
          return i;
        }
      }
    }

    if (path.isEmpty) {
      return 0;
    }

    return null;
  }
}

class _FooterNavigationSheet extends StatelessWidget {
  const _FooterNavigationSheet({
    required this.tabs,
    required this.currentIndex,
    required this.isExpanded,
    required this.isHomeContext,
    required this.allowToggle,
    this.onToggle,
    required this.onSelect,
  });

  static const double _collapsedBaseHeight = 120;
  static const double _expandedBaseHeight = 260;

  static double heightFor(bool isExpanded, double bottomInset) {
    return (isExpanded ? _expandedBaseHeight : _collapsedBaseHeight) +
        bottomInset;
  }

  final List<_TabDefinition> tabs;
  final int currentIndex;
  final bool isExpanded;
  final bool isHomeContext;
  final bool allowToggle;
  final VoidCallback? onToggle;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final effectiveHeight = heightFor(isExpanded, bottomInset);
    final bool showHandle = allowToggle && onToggle != null;
    final handleFill = isHomeContext
        ? Colors.white.withOpacity(0.18)
        : const Color(0xFFE8EBF6);
    final handleIconColor = isHomeContext
        ? Colors.white
        : const Color(0xFF1F2937);

    final Decoration? decoration = isHomeContext
        ? null
        : const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, -10),
              ),
            ],
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: effectiveHeight,
      padding: EdgeInsets.fromLTRB(
        16,
        isHomeContext ? 0 : 4,
        16,
        bottomInset + (isExpanded ? 0 : 12),
      ),
      decoration: decoration,
      color: isHomeContext ? Colors.transparent : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  color: handleFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: handleIconColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 0),
          ] else
            const SizedBox(height: 0),
          if (isExpanded)
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isSelected = index == currentIndex;
                    return _FooterNavTile(
                      tab: tab,
                      isSelected: isSelected,
                      isHomeContext: isHomeContext,
                      onTap: () => onSelect(index),
                    );
                  },
                ),
              ),
            )
          else
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tab = tabs[index];
                  final isSelected = index == currentIndex;
                  return _FooterNavCompactTile(
                    tab: tab,
                    isSelected: isSelected,
                    isHomeContext: isHomeContext,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FooterNavTile extends StatelessWidget {
  const _FooterNavTile({
    required this.tab,
    required this.isSelected,
    required this.isHomeContext,
    required this.onTap,
  });

  final _TabDefinition tab;
  final bool isSelected;
  final bool isHomeContext;
  final VoidCallback onTap;

  static const Color _tileColor = Color(0xFF1C47AD);
  static const Color _selectedAccent = Color(0xFFFFD54F);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackground = isHomeContext
        ? _tileColor.withOpacity(0.85)
        : _tileColor;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.28 : 0.16),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 28,
              color: isSelected ? _selectedAccent : Colors.white,
            ),
            Text(
              tab.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? _selectedAccent : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterNavCompactTile extends StatelessWidget {
  const _FooterNavCompactTile({
    required this.tab,
    required this.isSelected,
    required this.isHomeContext,
    required this.onTap,
  });

  final _TabDefinition tab;
  final bool isSelected;
  final bool isHomeContext;
  final VoidCallback onTap;

  static const Color _selectedAccent = Color(0xFFFFD54F);

  @override
  Widget build(BuildContext context) {
    final Color circleFill = isHomeContext
        ? Colors.white.withOpacity(0.18)
        : const Color(0xFFE9ECF7);
    final Color iconColor = isSelected
        ? _selectedAccent
        : (isHomeContext ? Colors.white : const Color(0xFF1F3C73));
    final Color textColor = isHomeContext
        ? Colors.white
        : const Color(0xFF1F2937);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: circleFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _selectedAccent : Colors.transparent,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(tab.icon, size: 22, color: iconColor),
          ),
          SizedBox(
            width: 72,
            child: Text(
              tab.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabDefinition {
  const _TabDefinition({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.matchingPrefixes,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final List<String> matchingPrefixes;
}
