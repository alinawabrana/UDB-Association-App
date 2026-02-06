import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/directory/screens/chat_screen.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';
import 'package:udb_association/utils/constants/urls.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  // Static coordinates for Libreville, Gabon (fallback)
  static const double _gabonLatitude = 0.3901;
  static const double _gabonLongitude = 9.4544;
  
  final MapController _mapController = MapController();
  
  // Get event coordinates or fallback to Gabon
  LatLng get _eventLocation {
    if (widget.event.latitude != null && widget.event.longitude != null) {
      final lat = double.tryParse(widget.event.latitude!) ?? _gabonLatitude;
      final lng = double.tryParse(widget.event.longitude!) ?? _gabonLongitude;
      return LatLng(lat, lng);
    }
    return const LatLng(_gabonLatitude, _gabonLongitude);
  }
  
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = l10n.locale.toLanguageTag();
    final imageUrl = ApiUrls.getMediaUrl(widget.event.image);

    // Format dates with actual time if available, otherwise use defaults
    final startTimeStr = widget.event.startTimeString ?? '14:00';
    final endTimeStr = widget.event.endTimeString ?? '01:00';
    final formattedStartTime = _formatTimeString(startTimeStr);
    final formattedEndTime = _formatTimeString(endTimeStr);
    
    final atLabel = l10n.translate('detail_at');
    final startDate = DateFormat('d MMMM yyyy', localeTag).format(widget.event.startDate) + ' $atLabel $formattedStartTime';
    final endDate = DateFormat('d MMMM yyyy', localeTag).format(widget.event.endDate) + ' $atLabel $formattedEndTime';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7B3A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Banner
            Container(
              width: double.infinity,
              height: 250,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.event,
                            color: Colors.grey[600],
                            size: 64,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.event,
                        color: Colors.grey[600],
                        size: 64,
                      ),
                    ),
            ),

            // Category Badge
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(widget.event.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.event.category.toUpperCase(),
                  style: TextStyle(
                    color: _getCategoryColor(widget.event.category),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Event Description Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDescriptionCard(context),
            ),
            const SizedBox(height: 24),

            // Date Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.translate('events_date_start'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        startDate,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // End Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.translate('events_date_end'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        endDate,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contact Person Section
                  Text(
                    l10n.translate('events_contact_person').toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contact Person Card
                  _buildContactPersonCard(context),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Map Section
            _buildMapSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    if (widget.event.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light mint green background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.event.description,
        style: const TextStyle(
          color: Color(0xFF388E3C), // Dark green text
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildContactPersonCard(BuildContext context) {
    final l10n = context.l10n;
    
    // Use event user if available
    if (widget.event.user == null) {
      // Return empty card or placeholder if no user
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            l10n.translate('events_no_contact_person'),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final user = widget.event.user!;
    final contactName = user.name.isNotEmpty ? user.name : (user.email.isNotEmpty ? user.email.split('@').first : 'User');
    final profileImage = user.profile?.profileImage;
    final profileImageUrl = profileImage != null
        ? ApiUrls.getProfileImageUrl(profileImage)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Contact Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF6B7B3A),
            ),
            child: profileImageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),

          // Contact Name
          Expanded(
            child: Text(
              contactName,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Chat Icon only
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    recipientId: user.id,
                    recipientName: user.name,
                    recipientProfession: user.role ?? '',
                    recipientImage: profileImageUrl,
                    chatType: 'user',
                  ),
                ),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF6B7B3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.message,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meeting':
        return const Color(0xFF2563EB);
      case 'event':
        return const Color(0xFF8FA654);
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Helper method to format time string (HH:mm or HH:mm:ss) to HH:mm
  String _formatTimeString(String timeString) {
    if (timeString.isEmpty) return '14:00';
    
    // Handle HH:mm:ss format - extract just HH:mm
    if (timeString.contains(':')) {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
    }
    
    return timeString;
  }

  Widget _buildMapSection(BuildContext context) {
    final l10n = context.l10n;
    
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              l10n.translate('events_location'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Map Container
          Container(
            height: 400,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _eventLocation,
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // OpenStreetMap tiles (free, no API key needed)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.udb_association',
                    maxZoom: 19,
                  ),
                  // Marker at event location
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _eventLocation,
                        width: 80.0,
                        height: 80.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF388E3C),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.event.location ?? 'Event Location',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(
                              Icons.location_pin,
                              color: Color(0xFF388E3C),
                              size: 40.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

