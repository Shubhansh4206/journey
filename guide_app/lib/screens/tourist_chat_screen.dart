import 'package:flutter/material.dart';
import '../models/guide_models.dart';
import '../state/guide_state.dart';
import '../theme/app_theme.dart';
import 'itinerary_map_screen.dart';
import 'sos_emergency_dialog.dart';

class TouristChatScreen extends StatefulWidget {
  final TourPackage package;
  final GuideState guideState;

  const TouristChatScreen({
    super.key,
    required this.package,
    required this.guideState,
  });

  @override
  State<TouristChatScreen> createState() => _TouristChatScreenState();
}

class _TouristChatScreenState extends State<TouristChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openMap() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text(
                  'Loading OpenStreetMap Route & Stops...',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final stops = await widget.guideState.getItineraryLocationsForPackage(widget.package);

    if (mounted) {
      Navigator.of(context).pop(); // dismiss loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItineraryMapScreen(
            items: stops,
            title: '${widget.package.title} - Route Map (OSM)',
            destination: widget.package.destination,
            payoutAmount: widget.package.payoutAmount,
            package: widget.package,
            guideState: widget.guideState,
          ),
        ),
      );
    }
  }

  void _openSosDialog() {
    SosEmergencyDialog.show(
      context,
      package: widget.package,
      guideState: widget.guideState,
    );
  }

  void _sendMessage({bool isAnnouncement = false}) {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    widget.guideState.sendMessage(
      widget.package.id,
      text,
      isAnnouncement: isAnnouncement,
    );
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickPreset(String preset) {
    widget.guideState.sendMessage(widget.package.id, preset);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTouristRosterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTouristRosterModal(),
    );
  }

  void _showBigTextBillboardModal(String text, {bool canSendToChat = true}) {
    final effectiveText = text.trim();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BigTextBillboardSheet(
        initialText: effectiveText.isNotEmpty
            ? effectiveText
            : 'MEET AT ${widget.package.meetingPoint.toUpperCase()} IN 10 MINUTES!',
        meetingPoint: widget.package.meetingPoint,
        canSendToChat: canSendToChat,
        onSendAnnouncement: (msg) {
          widget.guideState.sendMessage(
            widget.package.id,
            msg,
            isAnnouncement: true,
          );
          _messageController.clear();
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.volume_up_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '📣 Big Announcement broadcasted to all tourists in the chat!',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + 120,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.guideState,
      builder: (context, _) {
        final messages = widget.guideState.getMessagesForPackage(widget.package.id);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${widget.package.tourists.length} Travelers Connected • ${widget.package.destination}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.map_outlined, color: AppTheme.primary),
                tooltip: 'View Interactive Route (OSM)',
                onPressed: _openMap,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emergency_rounded, color: AppTheme.danger, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: AppTheme.danger,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                tooltip: 'Emergency SOS Alert',
                onPressed: _openSosDialog,
              ),
              IconButton(
                icon: const Icon(Icons.people_alt_outlined, color: AppTheme.primary),
                tooltip: 'View Booked Tourists Roster',
                onPressed: _showTouristRosterSheet,
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.secondary),
                tooltip: 'Big Text Loudspeaker Billboard',
                onPressed: () {
                  final text = _messageController.text;
                  _showBigTextBillboardModal(text, canSendToChat: true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.phone_in_talk_outlined, color: AppTheme.secondary),
                tooltip: 'Emergency Broadcast Call',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting Tour Group Voice Broadcast Channel...'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Active SOS banner across chat
              if (widget.guideState.isSosActive(widget.package.id))
                InkWell(
                  onTap: _openSosDialog,
                  child: Container(
                    width: double.infinity,
                    color: AppTheme.danger,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ACTIVE SOS: ${widget.guideState.activeSosAlert?.emergencyType ?? "Emergency"} • Operator Alerted • Tap for Console',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),

              // Pinned Meeting Location Notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppTheme.primaryLight,
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _openMap,
                        child: Text(
                          'Meeting Spot: ${widget.package.meetingPoint}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDark,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openMap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_rounded, size: 12, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Map',
                              style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('GPS Coordinates for ${widget.package.meetingPoint} shared with tourists!'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Share Pin',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages list
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 54, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'No messages yet in this tour channel',
                              style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Send a welcome announcement to your booked travelers!',
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
              ),

              // Quick action suggestions
              Container(
                height: 42,
                color: Colors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    _buildQuickActionChip('📍 Meeting Point Reminder', 'Reminder: Please meet at ${widget.package.meetingPoint} on time!'),
                    _buildQuickActionChip('🎒 Pack Gear Checklist', 'Please ensure you bring comfortable hiking shoes, rain gear, and personal medications.'),
                    _buildQuickActionChip('⏳ 15-Min Buffer Notice', 'Hey everyone! We have a quick 15-minute buffer before departure.'),
                    _buildQuickActionChip('☀️ Sun & Hydration Tip', 'Weather looks clear! Bring at least 1.5L water and sunscreen.'),
                  ],
                ),
              ),

              // Input Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: const Icon(Icons.volume_up_rounded, color: Color(0xFFD97706), size: 20),
                        ),
                        tooltip: 'Speaker: Make Chat Text BIGGG',
                        onPressed: () {
                          final text = _messageController.text;
                          _showBigTextBillboardModal(text, canSendToChat: true);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Message all ${widget.package.tourists.length} registered tourists...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          onPressed: () => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionChip(String label, String presetText) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.surfaceVariant,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        onPressed: () => _sendQuickPreset(presetText),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isGuide;

    if (msg.isSosAlert) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.danger, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.danger.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'EMERGENCY SOS ALERT • OPERATOR NOTIFIED',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.danger,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.danger, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.message,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF991B1B),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.support_agent_rounded, size: 14),
                  label: const Text('Operator Console', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  onPressed: _openSosDialog,
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.map_rounded, size: 14),
                  label: const Text('Route Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  onPressed: _openMap,
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (msg.isAnnouncement) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'OFFICIAL GUIDE ANNOUNCEMENT',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.fullscreen_rounded, color: AppTheme.secondary, size: 22),
                      tooltip: 'View in Fullscreen Big Text',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showBigTextBillboardModal(msg.message, canSendToChat: false),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // RENDERED BIGGG!
            Text(
              msg.message,
              style: const TextStyle(
                fontSize: 20, // BIGGG text!
                fontWeight: FontWeight.w800,
                color: Color(0xFF78350F),
                height: 1.35,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign_rounded, size: 14, color: Color(0xFFD97706)),
                    SizedBox(width: 4),
                    Text(
                      'Loudspeaker broadcasted',
                      style: TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showBigTextBillboardModal(msg.message, canSendToChat: false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, size: 14, color: AppTheme.secondary),
                        SizedBox(width: 4),
                        Text(
                          'Show Big Billboard',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.secondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(msg.senderAvatar),
              backgroundColor: AppTheme.surfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        msg.senderName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white.withValues(alpha: 0.7) : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _showBigTextBillboardModal(msg.message, canSendToChat: false),
                        child: Icon(
                          Icons.volume_up_rounded,
                          size: 13,
                          color: isMe ? Colors.white.withValues(alpha: 0.8) : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(msg.senderAvatar),
              backgroundColor: AppTheme.surfaceVariant,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTouristRosterModal() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booked Tourists Roster',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.package.tourists.length} registered parties • ${widget.package.currentBookings} total guests',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: widget.package.tourists.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tourist = widget.package.tourists[index];
                return _buildTouristRosterCard(tourist);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouristRosterCard(TouristUser tourist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(tourist.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tourist.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (tourist.isLeadBooker) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Lead',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tourist.country} • Party of ${tourist.partySize}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              // Contact buttons
              IconButton.filledTonal(
                icon: const Icon(Icons.phone_rounded, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${tourist.name} at ${tourist.phone}...'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening email draft to ${tourist.email}...'),
                      backgroundColor: AppTheme.info,
                    ),
                  );
                },
              ),
            ],
          ),
          if (tourist.dietaryOrSpecialNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt_outlined, color: Color(0xFFD97706), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Note: ${tourist.dietaryOrSpecialNotes}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Emergency Contact: ${tourist.emergencyContact}',
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Interactive High-Visibility Big Text Billboard & Loudspeaker Sheet
class _BigTextBillboardSheet extends StatefulWidget {
  final String initialText;
  final String meetingPoint;
  final bool canSendToChat;
  final ValueChanged<String>? onSendAnnouncement;

  const _BigTextBillboardSheet({
    required this.initialText,
    required this.meetingPoint,
    this.canSendToChat = true,
    this.onSendAnnouncement,
  });

  @override
  State<_BigTextBillboardSheet> createState() => _BigTextBillboardSheetState();
}

class _BigTextBillboardSheetState extends State<_BigTextBillboardSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _fontSize = 34.0;
  bool _isDarkContrast = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _adjustFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(22.0, 56.0);
    });
  }

  void _speakAloud() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSpeaking = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🔊 Loudspeaker Announcing: "$text"',
                style: const TextStyle(fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgCardColor = _isDarkContrast ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB);
    final textPrimaryColor = _isDarkContrast ? const Color(0xFFFBBF24) : const Color(0xFF78350F);
    final borderColor = _isDarkContrast ? const Color(0xFF334155) : const Color(0xFFFDE68A);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Loudspeaker badge, zoom controls, contrast toggle
          Row(
            children: [
              ScaleTransition(
                scale: _isSpeaking ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Icon(Icons.volume_up_rounded, color: Color(0xFFD97706), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LOUDSPEAKER BIG BILLBOARD',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'High-visibility text display for travelers',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              // Font size stepper
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _adjustFontSize(-4.0),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('A-', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: Colors.white,
                      child: Text(
                        '${_fontSize.toInt()}pt',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.secondary),
                      ),
                    ),
                    InkWell(
                      onTap: () => _adjustFontSize(4.0),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('A+', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // High contrast toggle
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: _isDarkContrast ? 'Switch to Day Light' : 'Switch to High Contrast Dark',
                icon: Icon(
                  _isDarkContrast ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppTheme.secondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _isDarkContrast = !_isDarkContrast),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick preset announcements chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPresetChip('📍 Meet at Spot', 'MEET AT ${widget.meetingPoint.toUpperCase()} NOW!'),
                _buildPresetChip('⏳ 5-Min Warning', '5 MINUTES UNTIL DEPARTURE! PLEASE GATHER'),
                _buildPresetChip('🚻 10-Min Break', '10-MINUTE RESTROOM & WATER BREAK'),
                _buildPresetChip('⚠️ Stay With Group', 'STAY CLOSE - CROWDED HERITAGE ZONE'),
                _buildPresetChip('📸 Photo Stop', '15-MINUTE PHOTO STOP AT MONUMENT'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── The BIGGG Text Billboard Card ─────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isDarkContrast ? 0.25 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    cursorColor: textPrimaryColor,
                    style: TextStyle(
                      fontSize: _fontSize, // BIGGG!
                      fontWeight: FontWeight.w900,
                      color: textPrimaryColor,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type announcement to make it BIGGG...',
                      hintStyle: TextStyle(
                        fontSize: _fontSize * 0.7,
                        color: textPrimaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Action Row
          Row(
            children: [
              // Speak aloud TTS button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD97706),
                  side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                label: Text(
                  _isSpeaking ? 'Speaking...' : 'Speak Aloud',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: _speakAloud,
              ),

              const SizedBox(width: 10),

              // Broadcast to group chat
              if (widget.canSendToChat)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.campaign_rounded, size: 20),
                    label: const Text(
                      'Broadcast to Chat (Big)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        widget.onSendAnnouncement?.call(text);
                      }
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String presetText) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF1F5F9),
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        onPressed: () {
          setState(() {
            _textController.text = presetText;
          });
        },
      ),
    );
  }
}

