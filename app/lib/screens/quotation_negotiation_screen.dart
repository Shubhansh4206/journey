import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/itinerary_node_model.dart';
import '../models/quotation_model.dart';
import '../services/quotation_negotiation_service.dart';
import '../utils/colors.dart';
import '../widgets/negotiate_price_sheet.dart';
import 'confirmed_trip_dashboard_screen.dart';
import 'quotation_payment_screen.dart';

class QuotationNegotiationScreen extends StatefulWidget {
  final String? tripRequestId;
  final String? quotationId;
  final String? destination;

  const QuotationNegotiationScreen({
    super.key,
    this.tripRequestId,
    this.quotationId,
    this.destination,
  });

  @override
  State<QuotationNegotiationScreen> createState() =>
      _QuotationNegotiationScreenState();
}

class _QuotationNegotiationScreenState
    extends State<QuotationNegotiationScreen> {
  final QuotationNegotiationService _negotiationService =
      QuotationNegotiationService();

  QuotationModel? _quotation;
  List<ItineraryNodeModel> _nodes = [];
  bool _isLoading = true;

  StreamSubscription<QuotationModel?>? _quoteSub;
  StreamSubscription<List<ItineraryNodeModel>>? _nodesSub;

  @override
  void initState() {
    super.initState();
    print('🎬 [SCREEN_INIT] QuotationNegotiationScreen mounted with tripRequestId="${widget.tripRequestId}", quotationId="${widget.quotationId}", destination="${widget.destination}"');
    _initData();
  }

  Future<void> _initData() async {
    print('===============================================================');
    print('🔍 [UI_INIT] Reading quotation from Supabase database...');
    print('   - Param tripRequestId: "${widget.tripRequestId}"');
    print('   - Param quotationId: "${widget.quotationId}"');
    print('   - Param destination: "${widget.destination}"');
    print('===============================================================');

    setState(() => _isLoading = true);

    QuotationModel? quote;

    // 1. Prioritize reading by trip_request_id from database
    if (widget.tripRequestId != null && widget.tripRequestId!.isNotEmpty) {
      print('🔍 [UI_INIT] Step 1: Querying Supabase quotations table where trip_request_id == "${widget.tripRequestId}"');
      quote = await _negotiationService.getQuotationByTripRequestId(widget.tripRequestId!);
    }

    // 2. Fallback to reading by quotationId from database
    if (quote == null && widget.quotationId != null && widget.quotationId!.isNotEmpty) {
      print('🔍 [UI_INIT] Step 2: Querying Supabase quotations table where id == "${widget.quotationId}"');
      quote = await _negotiationService.getQuotation(widget.quotationId!);
    }

    if (quote != null) {
      _quotation = quote;
      print('✅ [UI_INIT] Quotation found in database:');
      print('   - Quotation ID: ${quote.id}');
      print('   - Trip Request ID: ${quote.tripRequestId}');
      print('   - Title: ${quote.title}');
      print('   - Status: ${quote.status}');
      print('   - Total Price: ₹${quote.totalFinalPrice}, Per Person: ₹${quote.perPersonPrice}, Pax: ${quote.paxCount}');

      // Fetch itinerary nodes from database
      print('🔍 [UI_INIT] Step 3: Fetching itinerary nodes from database for quotation_id == "${quote.id}"...');
      final nodes = await _negotiationService.getItineraryNodes(quote.id);
      _nodes = nodes;
      print('✅ [UI_INIT] Loaded ${_nodes.length} nodes from database for quotation "${quote.id}":');
      for (int i = 0; i < _nodes.length; i++) {
        print('   [$i] ${_nodes[i].nodeType} - "${_nodes[i].title}" (finalPrice: ₹${nodes[i].finalPrice}, order: ${nodes[i].orderIndex})');
      }

      _subscribeRealtime(quote);
    } else {
      print('⚠️ [UI_INIT] No quotation found in database for trip_request_id: "${widget.tripRequestId}". Subscribing to Realtime stream to await operator submission...');
      _quotation = null;
      _nodes = [];
      if (widget.tripRequestId != null && widget.tripRequestId!.isNotEmpty) {
        _subscribeToAwaitingTripRequest(widget.tripRequestId!);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _subscribeToAwaitingTripRequest(String tripRequestId) {
    print('📡 [REALTIME_AWAIT] Listening for new quotation on trip_request_id: "$tripRequestId"');
    _quoteSub?.cancel();
    _quoteSub = _negotiationService
        .streamQuotationByTripRequestId(tripRequestId)
        .listen((updated) async {
      if (updated != null && mounted) {
        print('🎉 [REALTIME_AWAIT] Received quotation from operator! ID="${updated.id}", status="${updated.status}"');
        final nodes = await _negotiationService.getItineraryNodes(updated.id);
        setState(() {
          _quotation = updated;
          _nodes = nodes;
        });
        _subscribeRealtime(updated);
      }
    });
  }

  void _subscribeRealtime(QuotationModel quote) {
    _quoteSub?.cancel();

    // Stream quotations table by trip_request_id
    if (quote.tripRequestId.isNotEmpty) {
      print('📡 [REALTIME] Subscribing to quotations table filtering by trip_request_id: "${quote.tripRequestId}"');
      _quoteSub = _negotiationService
          .streamQuotationByTripRequestId(quote.tripRequestId)
          .listen((updated) {
        print('📡 [REALTIME_UPDATE] Quotation stream update received! Status="${updated?.status}", Total=₹${updated?.totalFinalPrice}');
        if (updated != null && mounted) {
          setState(() {
            _quotation = updated;
          });
        }
      });
    } else {
      print('📡 [REALTIME] Subscribing to quotations table filtering by ID: "${quote.id}"');
      _quoteSub = _negotiationService
          .streamQuotation(quote.id)
          .listen((updated) {
        print('📡 [REALTIME_UPDATE] Quotation stream update received for ID "${quote.id}"! Status="${updated?.status}", Total=₹${updated?.totalFinalPrice}');
        if (updated != null && mounted) {
          setState(() {
            _quotation = updated;
          });
        }
      });
    }

    print('📡 [REALTIME] Subscribing to itinerary_nodes table for quotation_id: "${quote.id}"');
    _nodesSub?.cancel();
    _nodesSub = _negotiationService.streamItineraryNodes(quote.id).listen((nodes) {
      print('📡 [REALTIME_UPDATE] Itinerary nodes stream update! Received ${nodes.length} nodes from database.');
      if (nodes.isNotEmpty && mounted) {
        setState(() {
          _nodes = nodes;
        });
      }
    });
  }

  @override
  void dispose() {
    print('🧹 [SCREEN_DISPOSE] Cleaning up streams...');
    _quoteSub?.cancel();
    _nodesSub?.cancel();
    super.dispose();
  }

  // ── Drag & Drop Handlers ──────────────────────────────────────────────────
  void _onReorder(int oldIndex, int newIndex) {
    print('🔄 [UI_REORDER] Drag & drop event triggered: oldIndex=$oldIndex, newIndex=$newIndex');

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _nodes.removeAt(oldIndex);
      _nodes.insert(newIndex, item);
      print('   👉 Moved "${item.title}" to position $newIndex');
    });

    print('📋 [UI_REORDER] New order in memory:');
    for (int i = 0; i < _nodes.length; i++) {
      print('   $i. [${_nodes[i].nodeType}] ${_nodes[i].title}');
    }

    // Fire Supabase updates for new order
    print('🚀 [UI_REORDER] Sending batch coordinate updates to Supabase...');
    _negotiationService.batchUpdateNodeOrder(_nodes);
  }

  // ── Counter Offer Action ──────────────────────────────────────────────────
  Future<void> _handleCounterOffer(
    double newTotalPrice,
    double perPersonPrice,
    String? notes,
  ) async {
    if (_quotation == null) return;
    print('🚀 [UI_COUNTER] User counter offer: newTotal=₹$newTotalPrice, perPerson=₹$perPersonPrice, notes="$notes"');

    // Optimistic UI update
    setState(() {
      _quotation = _quotation!.copyWith(
        status: 'user_countered',
        totalFinalPrice: newTotalPrice,
        perPersonPrice: perPersonPrice,
        customerNotes: notes,
      );
    });

    await _negotiationService.submitCounterOffer(
      quotationId: _quotation!.id,
      newTotalPrice: newTotalPrice,
      perPersonPrice: perPersonPrice,
      customerNotes: notes,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Counter-offer of ₹${newTotalPrice.toStringAsFixed(0)} sent to local operator!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primaryDarkBlue,
        ),
      );
    }
  }

  // ── Accept Quotation Action -> Updates status to 'finalised' ──────────────
  Future<void> _handleAcceptQuote() async {
    if (_quotation == null) return;
    print('🎉 [UI_ACCEPT] User accepted quotation ID: "${_quotation!.id}"');

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF059669), size: 24),
            ),
            const SizedBox(width: 10),
            Text(
              'Accept Quotation',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.nearBlack,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to accept this itinerary proposal of ₹${_quotation!.totalFinalPrice.toStringAsFixed(0)} (₹${_quotation!.perPersonPrice.toStringAsFixed(0)} / person)? This will finalize your journey booking.',
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirm & Accept',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _quotation = _quotation!.copyWith(status: 'finalised');
    });

    final success = await _negotiationService.acceptQuotation(
      quotationId: _quotation!.id,
      tripRequestId: _quotation!.tripRequestId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Quotation accepted! Status is now finalised.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update quotation status. Please check your connection.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  // ── Decline Quotation Action -> Updates status to 'declined' ──────────────
  Future<void> _handleDeclineQuote() async {
    if (_quotation == null) return;
    print('🚫 [UI_DECLINE] User initiated decline for quotation ID: "${_quotation!.id}"');

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_rounded,
                  color: Color(0xFFDC2626), size: 24),
            ),
            const SizedBox(width: 10),
            Text(
              'Decline Quotation',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.nearBlack,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to decline this itinerary quote? This will update the status to declined.',
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Keep Reviewing',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Yes, Decline',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _quotation = _quotation!.copyWith(status: 'declined');
    });

    final success = await _negotiationService.declineQuotation(
      quotationId: _quotation!.id,
      tripRequestId: _quotation!.tripRequestId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quotation declined.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF475569),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update quotation status. Please check your connection.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quotation;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.nearBlack, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote?.title ?? 'Trip Negotiation',
              style: GoogleFonts.poppins(
                color: AppColors.nearBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Realtime Ping-Pong Operator Sync',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.primaryDarkBlue),
            onPressed: () {
              print('🔄 [APPBAR] Manual refresh requested.');
              _initData();
            },
            tooltip: 'Sync Realtime Quote',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.primaryDarkBlue),
            onSelected: (val) async {
              if (val == 'toggle_status') {
                if (_quotation == null) return;
                final newStatus = _quotation!.isOperatorProposed
                    ? 'user_countered'
                    : 'operator_proposed';
                print('🧪 [DEBUG_TOGGLE] Updating database quotation status to "$newStatus"');
                setState(() {
                  _quotation = _quotation!.copyWith(status: newStatus);
                });
                await _negotiationService.submitCounterOffer(
                  quotationId: _quotation!.id,
                  newTotalPrice: _quotation!.totalFinalPrice,
                  perPersonPrice: _quotation!.perPersonPrice,
                  customerNotes: 'Status toggle from Flutter App',
                );
              }
            },
            itemBuilder: (ctx) => [
              if (_quotation != null)
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _quotation?.isOperatorProposed == true
                            ? 'Simulate Counter (Lock UI)'
                            : 'Simulate Operator Offer (Unlock UI)',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryDarkBlue,
              ),
            )
          : (quote == null)
              ? _buildAwaitingOperatorQuoteView()
              : Column(
                  children: [
                    // ── 1. Realtime Status Banner (Phase 1) ──────────────────────
                    _buildStatusHeader(quote),

                    // ── 2. Vertical Timeline Canvas (Phase 2 Drag & Drop) ───────
                    Expanded(
                      child: _nodes.isEmpty
                          ? _buildEmptyNodesView()
                          : _buildVerticalTimelineCanvas(quote),
                    ),

                    // ── 3. Bottom Action Bar ────────────────────────────────────
                    _buildBottomActionBar(quote),
                  ],
                ),
    );
  }

  // ── 1. Phase 1: Real-Time State Status Banner ─────────────────────────────
  Widget _buildStatusHeader(QuotationModel quote) {
    final isLocked = quote.isLocked;
    final isProposed = quote.isOperatorProposed;
    final isAccepted = quote.isAccepted;

    Color bg;
    Color border;
    Color iconColor;
    IconData icon;
    String statusTitle;
    String statusSub;

    if (quote.isFinalised) {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      iconColor = const Color(0xFF059669);
      icon = Icons.verified_rounded;
      statusTitle = 'Deal Finalised & Booked';
      statusSub =
          'All squad terms locked and verified. Proceed to vouchers & dashboard.';
    } else if (quote.isRejected) {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      iconColor = const Color(0xFFDC2626);
      icon = Icons.cancel_rounded;
      statusTitle = 'Quotation Rejected';
      statusSub = 'This quotation offer was declined or rejected.';
    } else if (quote.isSent) {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFFBFDBFE);
      iconColor = const Color(0xFF2563EB);
      icon = Icons.local_offer_rounded;
      statusTitle = 'Quotation Ready for Review';
      statusSub =
          'Review the customized itinerary activities, schedule, and pricing.';
    } else if (quote.isCountered) {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      iconColor = const Color(0xFFD97706);
      icon = Icons.hourglass_top_rounded;
      statusTitle = 'Countered · In Operator Review';
      statusSub =
          'Counter bid submitted. Canvas is locked in read-only mode while operator reviews.';
    } else {
      // draft
      bg = const Color(0xFFF8FAFC);
      border = const Color(0xFFE2E8F0);
      iconColor = const Color(0xFF64748B);
      icon = Icons.edit_note_rounded;
      statusTitle = 'Draft Quotation';
      statusSub =
          'Tour operator is structuring costs and activities for this itinerary.';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.nearBlack,
                      ),
                    ),
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LOCKED',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusSub,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Phase 2: Vertical Timeline Canvas (Drag & Drop) ────────────────────
  Widget _buildVerticalTimelineCanvas(QuotationModel? quote) {
    final isLocked = quote?.isLocked ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Itinerary Sequence',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.nearBlack,
                ),
              ),
              Text(
                isLocked
                    ? 'Read-Only Mode'
                    : 'Drag & Drop Activities to Reorder',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? AppColors.textMuted : AppColors.primaryDarkBlue,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.black.withValues(alpha: 0.1),
            ),
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _nodes.length,
              onReorder: (oldIdx, newIdx) {
                print('👉 [REORDER_GESTURE] User drag completed from $oldIdx to $newIdx');
                final sourceNode = _nodes[oldIdx];
                if (!sourceNode.isDraggable) {
                  print('⛔ [REORDER_GUARDRAIL] Node "${sourceNode.title}" (${sourceNode.nodeType}) is a fixed core and cannot be moved.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${sourceNode.nodeType} is a fixed anchor and cannot be moved.',
                        style: GoogleFonts.poppins(),
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.primaryDarkBlue,
                    ),
                  );
                  return;
                }
                if (isLocked) {
                  print('⚠️ [REORDER_GUARDRAIL] Canvas is currently locked (status: ${quote?.status}). Cannot reorder.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cannot reorder while quotation is in review mode.',
                        style: GoogleFonts.poppins(),
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFFD97706),
                    ),
                  );
                  return;
                }
                _onReorder(oldIdx, newIdx);
              },
              itemBuilder: (context, index) {
                final node = _nodes[index];
                return _buildTimelineNodeCard(
                  key: ValueKey(node.id),
                  node: node,
                  index: index,
                  isLocked: isLocked,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineNodeCard({
    required Key key,
    required ItineraryNodeModel node,
    required int index,
    required bool isLocked,
  }) {
    final isDraggable = node.isDraggable;
    final isHotel = node.nodeType == 'HOTEL';
    final isTransfer = node.nodeType == 'TRANSFER' || node.nodeType == 'TRANSPORT';
    final isFlight = node.nodeType == 'FLIGHT';

    IconData nodeIcon;
    Color nodeColor;

    if (isHotel) {
      nodeIcon = Icons.hotel_rounded;
      nodeColor = const Color(0xFFD97706);
    } else if (isFlight) {
      nodeIcon = Icons.flight_takeoff_rounded;
      nodeColor = const Color(0xFF4F46E5);
    } else if (isTransfer) {
      nodeIcon = Icons.directions_car_rounded;
      nodeColor = const Color(0xFF2563EB);
    } else {
      nodeIcon = Icons.explore_rounded;
      nodeColor = const Color(0xFF10B981);
    }

    return Material(
      key: key,
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: node.isFixedCore
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFCBD5E1),
            width: node.isFixedCore ? 1 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showNodeDetailFromDatabase(context, node),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Order number / Step
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: nodeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(nodeIcon, size: 16, color: nodeColor),
                  ),
                ),
                const SizedBox(width: 14),

                // Node details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: nodeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DAY ${node.dayNumber} · ${node.nodeType}',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: nodeColor,
                              ),
                            ),
                          ),
                          if (node.isFixedCore) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock_rounded,
                                      size: 10, color: Color(0xFF64748B)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Fixed Base',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        node.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.nearBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (node.locationSubtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          node.locationSubtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (node.timeSlot != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              node.timeSlot!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Drag handle or Lock icon
                if (isDraggable)
                  ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? const Color(0xFFF1F5F9)
                            : AppColors.softGrey,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLocked
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.drag_indicator_rounded,
                            color: isLocked
                                ? const Color(0xFF94A3B8)
                                : AppColors.primaryDarkBlue,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Node Database Lookup Modal ─────────────────────────────────────────────
  void _showNodeDetailFromDatabase(
      BuildContext context, ItineraryNodeModel initialNode) {
    final quotationId = _quotation?.id.isNotEmpty == true
        ? _quotation!.id
        : initialNode.quotationId;

    print('===============================================================');
    print('🔍 [NODE_CLICK] User clicked on node "${initialNode.title}"');
    print('   - Node ID: "${initialNode.id}"');
    print('   - Quotation ID: "$quotationId"');
    print('   - Searching Supabase itinerary_nodes table...');
    print('===============================================================');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return FutureBuilder<ItineraryNodeModel?>(
          future: _negotiationService.getNodeDetail(
            quotationId: quotationId,
            nodeId: initialNode.id,
          ),
          builder: (context, snapshot) {
            final node = snapshot.data ?? initialNode;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            Color nodeColor;
            IconData nodeIcon;
            if (node.nodeType == 'HOTEL') {
              nodeIcon = Icons.hotel_rounded;
              nodeColor = const Color(0xFFD97706);
            } else if (node.nodeType == 'FLIGHT') {
              nodeIcon = Icons.flight_takeoff_rounded;
              nodeColor = const Color(0xFF4F46E5);
            } else if (node.nodeType == 'TRANSFER' ||
                node.nodeType == 'TRANSPORT') {
              nodeIcon = Icons.directions_car_rounded;
              nodeColor = const Color(0xFF2563EB);
            } else {
              nodeIcon = Icons.explore_rounded;
              nodeColor = const Color(0xFF10B981);
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                top: 12,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle Pill
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header: Type Badge + Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: nodeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(nodeIcon, size: 14, color: nodeColor),
                            const SizedBox(width: 6),
                            Text(
                              node.nodeType,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: nodeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryDarkBlue,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 11, color: Color(0xFF059669)),
                              const SizedBox(width: 4),
                              Text(
                                'Synced from DB',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title & Location
                  Text(
                    node.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  if (node.locationSubtitle != null &&
                      node.locationSubtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 14, color: AppColors.primaryDarkBlue),
                        const SizedBox(width: 4),
                        Text(
                          node.locationSubtitle!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Financial Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FINANCIAL BREAKDOWN (POSTGRESQL)',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Base Cost (Operator)',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${node.baseCost.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.nearBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Margin Markup',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${node.marginPercentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Final Calculated Price',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.nearBlack,
                              ),
                            ),
                            Text(
                              '₹${node.finalPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDarkBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Node Database Metadata & Coordinates
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATABASE RECORD SPECIFICATIONS',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMetaRow('Node ID', node.id),
                        _buildMetaRow('Quotation ID', node.quotationId),
                        _buildMetaRow(
                            'Day Number', 'Day ${node.dayNumber}'),
                        _buildMetaRow('Order Index', '${node.orderIndex}'),
                        _buildMetaRow(
                            'UI Coordinates JSONB', node.uiCoordinates.toString()),
                        if (node.originalInventoryId != null)
                          _buildMetaRow('Inventory ID', node.originalInventoryId!),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Close Node Details',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNodesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alt_route_rounded,
                size: 54, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              'No Itinerary Nodes Yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Waiting for operator to structure your custom timeline.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwaitingOperatorQuoteView() {
    final tripReqId = widget.tripRequestId ?? widget.quotationId ?? '';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 48,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Awaiting Operator Quotation',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The tour operator is actively calculating costs and building your customized itinerary for Trip Request #${tripReqId.length > 8 ? tripReqId.substring(0, 8) : tripReqId}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Listening to database in Realtime...',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initData,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
              label: Text(
                'Check Database Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Floating Bottom Action Bar ─────────────────────────────────────────
  Widget _buildBottomActionBar(QuotationModel quote) {
    final isFinalised = quote.isFinalised;
    final isDeclined = quote.isDeclined;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Per Person',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.softGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${quote.paxCount} pax',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${quote.perPersonPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                Text(
                  'Total: ₹${quote.totalFinalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            // Action Buttons
            if (isFinalised)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConfirmedTripDashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard_rounded,
                    size: 16, color: Colors.white),
                label: Text(
                  'Trip Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              )
            else if (isDeclined)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_rounded,
                        size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    Text(
                      'Quotation Declined',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decline Button
                  OutlinedButton(
                    onPressed: _handleDeclineQuote,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(
                          color: Color(0xFFFCA5A5), width: 1.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Accept Button
                  ElevatedButton.icon(
                    onPressed: _handleAcceptQuote,
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 16, color: Colors.white),
                    label: Text(
                      'Accept',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
