import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../models/guide_models.dart';
import '../models/quotation_item_model.dart';
import '../state/guide_state.dart';
import '../theme/app_theme.dart';
import 'sos_emergency_dialog.dart';

class ItineraryMapScreen extends StatefulWidget {
  final String title;
  final String quotationId;
  final String tripRequestId;
  final String destination;
  final double payoutAmount;
  final List<ItineraryLocationItem> items;
  final bool isJustAccepted;
  final TourPackage? package;
  final GuideState? guideState;

  const ItineraryMapScreen({
    super.key,
    required this.title,
    this.quotationId = '',
    this.tripRequestId = '',
    required this.destination,
    this.payoutAmount = 0.0,
    required this.items,
    this.isJustAccepted = false,
    this.package,
    this.guideState,
  });

  @override
  State<ItineraryMapScreen> createState() => _ItineraryMapScreenState();
}

class _ItineraryMapScreenState extends State<ItineraryMapScreen> {
  final MapController _mapController = MapController();
  ItineraryLocationItem? _selectedItem;
  bool _showStopsList = true;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _selectedItem = widget.items.first;
    }
  }

  void _fitBounds() {
    if (widget.items.isEmpty) return;
    final points = widget.items.map((it) => it.coordinates).toList();
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(40, 80, 40, 240),
      ),
    );
  }

  void _focusLocation(ItineraryLocationItem item) {
    setState(() {
      _selectedItem = item;
    });
    _mapController.move(item.coordinates, 15.5);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hotel':
        return const Color(0xFF3B82F6); // Blue
      case 'place':
        return const Color(0xFF10B981); // Emerald
      case 'activity':
        return const Color(0xFFF59E0B); // Amber/Orange
      case 'transport':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return AppTheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'place':
        return Icons.account_balance_rounded;
      case 'activity':
        return Icons.local_activity_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  String _formatINR(num amount) {
    final int val = amount.round();
    return val.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final centerLatLng = widget.items.isNotEmpty
        ? widget.items.first.coordinates
        : const LatLng(18.9220, 72.8347);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.map_rounded, size: 12, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  '${widget.destination.toUpperCase()} • ${widget.items.length} STOPS (OSM)',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (widget.package != null && widget.guideState != null)
            ListenableBuilder(
              listenable: widget.guideState!,
              builder: (context, _) {
                final isSos = widget.guideState!.isSosActive(widget.package!.id);
                return IconButton(
                  tooltip: isSos ? 'SOS Alert Active (Operator Alerted)' : 'SOS Emergency Dispatch',
                  icon: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSos ? const Color(0xFFDC2626) : const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.crisis_alert_rounded,
                      color: isSos ? Colors.white : const Color(0xFFDC2626),
                      size: 18,
                    ),
                  ),
                  onPressed: () => SosEmergencyDialog.show(
                    context,
                    package: widget.package!,
                    guideState: widget.guideState!,
                  ),
                );
              },
            ),
          IconButton(
            tooltip: 'Fit All Stops',
            icon: const Icon(Icons.fullscreen_rounded, color: AppTheme.primary),
            onPressed: _fitBounds,
          ),
          IconButton(
            tooltip: _showStopsList ? 'Hide Stops' : 'Show Stops',
            icon: Icon(
              _showStopsList ? Icons.layers_clear_outlined : Icons.layers_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => setState(() => _showStopsList = !_showStopsList),
          ),
        ],
      ),
      body: widget.guideState != null
          ? ListenableBuilder(
              listenable: widget.guideState!,
              builder: (context, _) => _buildMapStack(centerLatLng),
            )
          : _buildMapStack(centerLatLng),
    );
  }

  Widget _buildMapStack(LatLng centerLatLng) {
    final isSosActive = widget.package != null &&
        widget.guideState != null &&
        widget.guideState!.isSosActive(widget.package!.id);

    return Stack(
      children: [
        // ── 1. OpenStreetMap Canvas (flutter_map) ──────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: centerLatLng,
            initialZoom: 13.5,
            onMapReady: () {
              Future.delayed(const Duration(milliseconds: 300), _fitBounds);
            },
          ),
          children: [
            // Standard OpenStreetMap Tile Server
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.journey.guide_app',
              maxZoom: 19,
            ),

            // Route Polyline connecting consecutive stops
            if (widget.items.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.items.map((it) => it.coordinates).toList(),
                    strokeWidth: 4.0,
                    color: AppTheme.primary.withValues(alpha: 0.8),
                  ),
                ],
              ),

            // Interactive Markers for each selected item
            MarkerLayer(
              markers: widget.items.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                final isSelected = _selectedItem?.id == item.id;
                final color = _getCategoryColor(item.category);

                return Marker(
                  point: item.coordinates,
                  width: isSelected ? 52 : 44,
                  height: isSelected ? 58 : 50,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () => _focusLocation(item),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 2.5 : 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(item.category),
                                color: Colors.white,
                                size: isSelected ? 14 : 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$index',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSelected ? 12 : 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomPaint(
                          size: const Size(10, 6),
                          painter: _TrianglePainter(color: isSelected ? Colors.black : color),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // ── 2. Top Info / Confirmation / SOS Banner ─────────────────────
        Positioned(
          top: 12,
          left: 14,
          right: 14,
          child: Column(
            children: [
              // Active SOS Emergency Banner
              if (isSosActive)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      if (widget.package != null && widget.guideState != null) {
                        SosEmergencyDialog.show(
                          context,
                          package: widget.package!,
                          guideState: widget.guideState!,
                        );
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.crisis_alert_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🚨 SOS ALERT ACTIVE: Tour Operator Alerted! Tap to contact operator.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                      ],
                    ),
                  ),
                ),

              if (widget.isJustAccepted)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tour Accepted! +₹${_formatINR(widget.payoutAmount)} added to Escrow',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // OSM Provider Tag Pill
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, size: 12, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text(
                        'OpenStreetMap Live',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── 3. SOS Floating Emergency Button (Left side) ───────────────
        if (widget.package != null && widget.guideState != null)
          Positioned(
            left: 14,
            bottom: _showStopsList ? 220 : 30,
            child: FloatingActionButton.extended(
              heroTag: 'osm_sos_btn',
              backgroundColor: isSosActive ? const Color(0xFF991B1B) : const Color(0xFFDC2626),
              elevation: 5,
              icon: const Icon(Icons.crisis_alert_rounded, color: Colors.white, size: 20),
              label: Text(
                isSosActive ? 'SOS (ALERTED)' : 'SOS SAFETY',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
              onPressed: () => SosEmergencyDialog.show(
                context,
                package: widget.package!,
                guideState: widget.guideState!,
              ),
            ),
          ),

        // ── 4. Floating Map Controls (Right side) ─────────────────────
        Positioned(
          right: 14,
          bottom: _showStopsList ? 220 : 30,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'osm_zoom_in',
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textPrimary,
                elevation: 3,
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom + 1.0);
                },
                child: const Icon(Icons.add, size: 18),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'osm_zoom_out',
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textPrimary,
                elevation: 3,
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom - 1.0);
                },
                child: const Icon(Icons.remove, size: 18),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'osm_fit_all',
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                onPressed: _fitBounds,
                child: const Icon(Icons.my_location_rounded, size: 18),
              ),
            ],
          ),
        ),

          // ── 4. Bottom Horizontal Itinerary Stops Tray ─────────────────
          if (_showStopsList)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tray Header: Selected Stop Details & Coordinates
                    if (_selectedItem != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(_selectedItem!.category).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedItem!.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: _getCategoryColor(_selectedItem!.category),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedItem!.duration,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.pin_drop_rounded, size: 12, color: AppTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedItem!.formattedCoordinates,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedItem!.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _selectedItem!.subtitle,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Horizontal Stops Ribbon
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.items.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final it = widget.items[index];
                          final isCurrent = _selectedItem?.id == it.id;
                          final color = _getCategoryColor(it.category);

                          return InkWell(
                            onTap: () => _focusLocation(it),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 160,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrent ? color : Colors.grey.shade200,
                                  width: isCurrent ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 9,
                                        backgroundColor: color,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          it.category,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    it.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
