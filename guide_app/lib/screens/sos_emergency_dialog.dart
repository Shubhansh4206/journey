import 'package:flutter/material.dart';
import '../models/guide_models.dart';
import '../state/guide_state.dart';
import '../theme/app_theme.dart';

class SosEmergencyDialog extends StatefulWidget {
  final TourPackage package;
  final GuideState guideState;

  const SosEmergencyDialog({
    super.key,
    required this.package,
    required this.guideState,
  });

  static Future<void> show(BuildContext context, {
    required TourPackage package,
    required GuideState guideState,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SosEmergencyDialog(
        package: package,
        guideState: guideState,
      ),
    );
  }

  @override
  State<SosEmergencyDialog> createState() => _SosEmergencyDialogState();
}

class _SosEmergencyDialogState extends State<SosEmergencyDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _notesController = TextEditingController();
  String _selectedEmergencyType = 'Medical Emergency';
  bool _isTransmitting = false;

  final List<Map<String, dynamic>> _emergencyTypes = [
    {'type': 'Medical Emergency', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFFEF4444)},
    {'type': 'Tourist Separated / Missing', 'icon': Icons.person_search_rounded, 'color': const Color(0xFFF97316)},
    {'type': 'Vehicle / Transport Breakdown', 'icon': Icons.car_crash_rounded, 'color': const Color(0xFFEAB308)},
    {'type': 'Severe Weather / Hazard', 'icon': Icons.thunderstorm_rounded, 'color': const Color(0xFF8B5CF6)},
    {'type': 'Security / Safety Threat', 'icon': Icons.shield_rounded, 'color': const Color(0xFFDC2626)},
    {'type': 'General Urgent Assistance', 'icon': Icons.warning_rounded, 'color': const Color(0xFFD97706)},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // If no alert active yet for this package, trigger on open
    if (!widget.guideState.isSosActive(widget.package.id)) {
      _triggerSos();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _triggerSos() async {
    setState(() => _isTransmitting = true);
    await widget.guideState.triggerSosAlert(
      package: widget.package,
      emergencyType: _selectedEmergencyType,
      notes: _notesController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _isTransmitting = false;
      });
    }
  }

  void _callOperator(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Connecting to Tour Operator Dispatch: $phone...',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _sendSmsDispatch(TourOperatorContact op) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emergency Signal & GPS packet dispatched to ${op.email}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _callLocalService(String serviceName, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dialing $serviceName ($number)...'),
        backgroundColor: const Color(0xFFB91C1C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resolveSos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Stand Down SOS Alert?'),
          ],
        ),
        content: const Text(
          'Confirm that the emergency situation is under control, the tour operator is updated, and tourists are safe. An all-clear notice will be broadcast.',
          style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            onPressed: () {
              final activeAlert = widget.guideState.activeSosAlert;
              if (activeAlert != null) {
                widget.guideState.resolveSosAlert(
                  activeAlert.id,
                  notes: _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : 'Resolved by tour guide in field.',
                );
              }
              Navigator.of(ctx).pop(); // Close confirm dialog
              Navigator.of(context).pop(); // Close SOS modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ SOS Emergency Protocol successfully resolved. Tour resumed.'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Resolution'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const operator = TourOperatorContact();
    final activeAlert = widget.guideState.activeSosAlert;
    final tourists = widget.package.tourists;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Column(
          children: [
            // ── 1. Pulsing Red Emergency Header ──────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        color: Color(0xFFDC2626),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                activeAlert != null
                                    ? 'ALERT #${activeAlert.id.substring(0, 8).toUpperCase()}'
                                    : 'LIVE SOS BEACON',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_isTransmitting)
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'TOUR OPERATOR ALERTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          widget.package.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Minimize Dialog (SOS Remains Active)',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── 2. Scrollable Body ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  // Status Transmission Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.radio_button_checked_rounded, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emergency Dispatch Packet Transmitted',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Location: ${widget.package.meetingPoint} • Guide: ${widget.guideState.currentGuide.name} • ${tourists.length} Parties (${widget.package.currentBookings} Guests)',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── SECTION A: CONTACT TOUR OPERATOR (Primary Feature) ────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDC2626), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.headset_mic_rounded, color: Color(0xFFDC2626), size: 20),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tour Operator Operations Desk',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '24/7 PRIORITY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          operator.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        ),
                        Text(
                          operator.dutyDesk,
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 14),

                        // Big Call Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.call_rounded, size: 20),
                            label: Text(
                              'CALL OPERATOR HOTLINE (${operator.hotlinePhone})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            onPressed: () => _callOperator(operator.hotlinePhone),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Secondary Operator Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF991B1B),
                                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.phone_forwarded_rounded, size: 16),
                                label: Text(operator.secondaryPhone, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                onPressed: () => _callOperator(operator.secondaryPhone),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.message_rounded, size: 16),
                                label: const Text('Dispatch Signal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                onPressed: () => _sendSmsDispatch(operator),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── SECTION B: EMERGENCY TYPE SELECTOR ─────────────────────
                  const Text(
                    'Select Nature of Emergency',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emergencyTypes.map((item) {
                      final isSelected = _selectedEmergencyType == item['type'];
                      final color = item['color'] as Color;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedEmergencyType = item['type'] as String);
                          _triggerSos();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? color : color.withValues(alpha: 0.3),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 14,
                                color: isSelected ? Colors.white : color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['type'] as String,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Incident Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add incident details (e.g. guest fell near fountain, need ambulance)...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppTheme.primary, size: 18),
                        tooltip: 'Broadcast Notes to Operator & Chat',
                        onPressed: () {
                          if (_notesController.text.trim().isNotEmpty) {
                            widget.guideState.sendMessage(
                              widget.package.id,
                              '⚠️ [INCIDENT UPDATE] ${_notesController.text.trim()}',
                              isAnnouncement: true,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incident note logged and broadcast to group chat.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── SECTION C: LOCAL EMERGENCY SERVICES QUICK DIAL ─────────
                  const Text(
                    'Local Emergency Hotlines',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildEmergencyPill('112', 'National Emergency', Icons.emergency_rounded, const Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      _buildEmergencyPill('108', 'Medical Ambulance', Icons.local_hospital_rounded, const Color(0xFF059669)),
                      const SizedBox(width: 8),
                      _buildEmergencyPill('100', 'Police Control', Icons.local_police_rounded, const Color(0xFF2563EB)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── SECTION D: TOURIST NEXT-OF-KIN EMERGENCY CONTACTS ──────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tourists Next-of-Kin Contacts',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      Text(
                        '${tourists.length} Parties',
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...tourists.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(t.avatarUrl),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.name,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Emergency: ${t.emergencyContact.isNotEmpty ? t.emergencyContact : "Not registered"}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call_rounded, color: AppTheme.primary, size: 18),
                              tooltip: 'Call Tourist',
                              onPressed: () => _callOperator(t.phone),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // ── 3. Bottom Action Bar ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      label: const Text('Minimize Modal'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Resolve & Stand Down', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: _resolveSos,
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

  Widget _buildEmergencyPill(String number, String label, IconData icon, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () => _callLocalService(label, number),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                number,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
