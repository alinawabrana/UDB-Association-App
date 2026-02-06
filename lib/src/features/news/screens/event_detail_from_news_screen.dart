import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';
import 'package:udb_association/utils/constants/urls.dart';

class EventDetailFromNewsScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailFromNewsScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<EventDetailFromNewsScreen> createState() => _EventDetailFromNewsScreenState();
}

class _EventDetailFromNewsScreenState extends ConsumerState<EventDetailFromNewsScreen> {
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
    
    // Format start date with actual time if available, otherwise use default
    final startTimeStr = widget.event.startTimeString ?? '14:00';
    final formattedStartTime = _formatTimeString(startTimeStr);
    
    final atLabel = l10n.translate('detail_at');
    final startDate = DateFormat('d MMMM yyyy', localeTag).format(widget.event.startDate) + ' $atLabel $formattedStartTime';
    
    // Publisher name (if available)
    final publisherName = widget.event.user?.name;

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Start Date & Time
                  Text(
                    startDate,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Publisher Name (if available)
                  if (publisherName != null) ...[
                    Row(
                      children: [
                        Text(
                          l10n.translate('detail_author_label'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          publisherName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Details/Description Card
                  Container(
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
                  ),
                  const SizedBox(height: 24),

                  // Event Image Banner
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 200),
                    child: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.grey[600],
                                    size: 64,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.event,
                              color: Colors.grey[600],
                              size: 64,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            
            // Map Section
            _buildMapSection(context),
          ],
        ),
      ),
    );
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

