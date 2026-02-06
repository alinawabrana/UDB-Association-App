import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/router/app_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(profileProvider);
    final l10n = context.l10n;

    return userProfileAsync.when(
      data: (user) => _buildDrawerContent(context, l10n, user.role ?? 'user'),
      loading: () => _buildLoadingDrawer(),
      error: (_, __) => _buildErrorDrawer(context, l10n),
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    AppLocalizations l10n,
    String userRole,
  ) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F7F7),
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B7C32), Color(0xFF8A9B5C)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/icons/handshake_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('udb_association'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translate('drawer_explore_services'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content based on user role
          Expanded(child: _buildRoleBasedContent(context, l10n, userRole)),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.translate('drawer_footer'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBasedContent(
    BuildContext context,
    AppLocalizations l10n,
    String userRole,
  ) {
    final roleLower = userRole.toLowerCase();
    if (roleLower == 'user') {
      return _buildBecomeMemberContent(context, l10n);
    }

    if (roleLower == 'vendor') {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _DrawerMenuItem(
            icon: Icons.insights_outlined,
            title: l10n.translate('statistics'),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRouteNames.statistics);
            },
          ),
        ],
      );
    }

    final menuItems = <_DrawerAction>[];

    if (roleLower == 'member' || roleLower == 'manager') {
      menuItems.add(
        _DrawerAction(
          icon: Icons.folder_outlined,
          title: l10n.translate('documents'),
          routeName: AppRouteNames.appDocuments,
        ),
      );
    }

    if (roleLower == 'member') {
      menuItems.add(
        _DrawerAction(
          icon: Icons.assignment_outlined,
          title: l10n.translate('surveys'),
          routeName: AppRouteNames.appSurveys,
        ),
      );
    }

    if (roleLower == 'manager') {
      menuItems.add(
        _DrawerAction(
          icon: Icons.bar_chart_outlined,
          title: l10n.translate('drawer_survey_analysis'),
          routeName: AppRouteNames.surveyAnalysis,
        ),
      );
    }

    if (roleLower == 'manager') {
      final statsRoute = AppRouteNames.managerStatistics;
      menuItems.add(
        _DrawerAction(
          icon: Icons.insights_outlined,
          title: l10n.translate('statistics'),
          routeName: statsRoute,
        ),
      );
    }

    if (menuItems.isEmpty) {
      return _buildBecomeMemberContent(context, l10n);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: menuItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _DrawerMenuItem(
          icon: item.icon,
          title: item.title,
          onTap: () {
            Navigator.pop(context);
            context.goNamed(item.routeName);
          },
        );
      },
    );
  }

  Widget _buildBecomeMemberContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        // Become a Member Card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.translate('drawer_premium_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('drawer_premium_description'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/profile/subscription_selection?type=member');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.translate('drawer_become_member_button'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Empty space to center the card
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildLoadingDrawer() {
    return const Drawer(
      backgroundColor: Color(0xFFF7F7F7),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorDrawer(BuildContext context, AppLocalizations l10n) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F7F7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              l10n.translate('drawer_error_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('common_close')),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7C32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF6B7C32), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAction {
  const _DrawerAction({
    required this.icon,
    required this.title,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String routeName;
}
