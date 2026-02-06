import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/notifications/providers/notification_providers.dart';
import 'package:udb_association/utils/constants/urls.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _eventReminders = true;
  bool _newPosts = true;
  bool _announcements = false;
  bool _soundSelected = true;
  bool _vibrationSelected = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7B4F),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(6),
              child: Image.asset('assets/icons/handshake_icon.png'),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.translate('udb_association'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final profileAsync = ref.watch(profileProvider);
              return profileAsync.when(
                data: (user) {
                  final profileImageUrl = ApiUrls.getProfileImageUrl(
                    user.profile?.profileImage,
                  );
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: profileImageUrl.isNotEmpty
                          ? Image.network(
                              profileImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                    ),
                  );
                },
                loading: () => Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                error: (error, stack) => Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              height: 215,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B7B4F), Color(0xFF5A6B43)],
                  stops: [0.0, 0.7071],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.notification5,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.translate('notifications_header_title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('notifications_header_subtitle'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Body Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification Settings Card
                  // _buildNotificationSettingsCard(),
                  // const SizedBox(height: 16),

                  // Recent Notifications Section
                  _buildRecentNotificationsSection(),
                  const SizedBox(height: 16),

                  // Smart Notifications Card
                  // _buildSmartNotificationsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildNotificationSettingsCard() {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Iconsax.setting_44,
                  size: 20,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('notifications_settings_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Settings Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Iconsax.calendar_tick5,
                  iconBgColor: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF2563EB),
                  title: l10n.translate('notifications_event_title'),
                  subtitle: l10n.translate('notifications_event_subtitle'),
                  value: _eventReminders,
                  onChanged: (value) => setState(() => _eventReminders = value),
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  icon: Icons.newspaper,
                  iconBgColor: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  title: l10n.translate('notifications_posts_title'),
                  subtitle: l10n.translate('notifications_posts_subtitle'),
                  value: _newPosts,
                  onChanged: (value) => setState(() => _newPosts = value),
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  icon: null, // We'll handle the custom icon in the widget
                  iconBgColor: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF9333EA),
                  title: l10n.translate('notifications_announcements_title'),
                  subtitle: l10n.translate(
                    'notifications_announcements_subtitle',
                  ),
                  value: _announcements,
                  onChanged: (value) => setState(() => _announcements = value),
                  customIcon: Image.asset(
                    'assets/icons/announcement_icon.png',
                    width: 20,
                    height: 20,
                    color: const Color(0xFF9333EA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData? icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? customIcon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Center(
            child: customIcon ?? Icon(icon, color: iconColor, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 48,
            height: 26,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF6B7B4F) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: value ? 24 : 2,
                  top: 2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentNotificationsSection() {
    final l10n = context.l10n;
    final notificationsAsync = ref.watch(enhancedNotificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Iconsax.clock5, size: 20, color: Color(0xFF6B7B4F)),
            const SizedBox(width: 8),
            Text(
              l10n.translate('notifications_recent_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notification Cards
        notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    l10n.translate('notifications_empty'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: List.generate(notifications.length, (index) {
                final notification = notifications[index];
                final colorIndex = index % 3;

                // Define colors for 1st, 2nd, 3rd, and repeat
                final colors = [
                  {
                    'border': const Color(0xFF3B82F6),
                    'bg': const Color(0xFFDBEAFE),
                    'icon': const Color(0xFF2563EB),
                    'time': const Color(0xFF2563EB),
                  },
                  {
                    'border': const Color(0xFF22C55E),
                    'bg': const Color(0xFFDCFCE7),
                    'icon': const Color(0xFF16A34A),
                    'time': const Color(0xFF16A34A),
                  },
                  {
                    'border': const Color(0xFF6B7B4F),
                    'bg': const Color(0x338A9B6E),
                    'icon': const Color(0xFF6B7B4F),
                    'time': const Color(0xFF6B7B4F),
                  },
                ];

                final colorScheme = colors[colorIndex];
                final timeAgo = _getTimeAgo(l10n, notification.createdAt);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < notifications.length - 1 ? 12 : 0,
                  ),
                  child: _buildNotificationCard(
                    l10n: l10n,
                    borderColor: colorScheme['border'] as Color,
                    iconBgColor: colorScheme['bg'] as Color,
                    iconColor: colorScheme['icon'] as Color,
                    timeColor: colorScheme['time'] as Color,
                    icon: Iconsax.notification5,
                    title: notification.title,
                    subtitle: notification.message,
                    timeAgo: timeAgo,
                    isRead: notification.isRead,
                    notificationId: notification.id,
                  ),
                );
              }),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                l10n.translate('notifications_load_failed'),
                style: const TextStyle(fontSize: 14, color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(AppLocalizations l10n, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n.translate(
        'chat_time_d_ago',
        params: {'days': difference.inDays.toString()},
      );
    } else if (difference.inHours > 0) {
      return l10n.translate(
        'chat_time_h_ago',
        params: {'hours': difference.inHours.toString()},
      );
    } else if (difference.inMinutes > 0) {
      return l10n.translate(
        'chat_time_m_ago',
        params: {'minutes': difference.inMinutes.toString()},
      );
    } else {
      return l10n.translate('chat_time_just_now');
    }
  }

  void _markAsRead(int notificationId) {
    ref
        .read(markAsReadProvider(notificationId).future)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.translate('notifications_mark_read_success'),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: const Color(0xFF6B7B4F),
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.translate(
                  'notifications_mark_read_failure',
                  params: {'error': error.toString()},
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  Widget _buildNotificationCard({
    required AppLocalizations l10n,
    required Color borderColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color timeColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required String timeAgo,
    required bool isRead,
    required int notificationId,
  }) {
    return GestureDetector(
      onTap: !isRead ? () => _markAsRead(notificationId) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                // Unread indicator
                if (!isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                            // Make unread notifications slightly bolder
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      // Unread tag
                      if (!isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.translate('notifications_badge_new'),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: timeColor,
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

  // ignore: unused_element
  Widget _buildSmartNotificationsCard() {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFEFF6FF), Color(0x1A8A9B6E)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.mobile,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('notifications_smart_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.translate('notifications_smart_subtitle'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _soundSelected = true;
                    _vibrationSelected = false;
                  }),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.volume_high,
                            size: 20,
                            color: _soundSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF6B7B4F),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.translate('notifications_sound'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _soundSelected = false;
                    _vibrationSelected = true;
                  }),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _vibrationSelected
                                ? Iconsax.mobile5
                                : Iconsax.mobile,
                            size: 20,
                            color: _vibrationSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF6B7B4F),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.translate('notifications_vibration'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
