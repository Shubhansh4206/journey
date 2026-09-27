import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quotation_model.dart';
import '../utils/colors.dart';

class NegotiatePriceSheet extends StatefulWidget {
  final QuotationModel quotation;
  final Future<void> Function(
    double newTotalPrice,
    double perPersonPrice,
    String? notes,
  ) onSubmit;

  const NegotiatePriceSheet({
    super.key,
    required this.quotation,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required QuotationModel quotation,
    required Future<void> Function(
      double newTotalPrice,
      double perPersonPrice,
      String? notes,
    ) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: NegotiatePriceSheet(
          quotation: quotation,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  @override
  State<NegotiatePriceSheet> createState() => _NegotiatePriceSheetState();
}

class _NegotiatePriceSheetState extends State<NegotiatePriceSheet> {
  late double _maxPrice;
  late double _minPrice;
  late double _currentPrice;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _maxPrice = widget.quotation.totalFinalPrice;
    // Strictly capped at 7% below the operator proposed price
    _minPrice = (_maxPrice * 0.93).roundToDouble();
    // Default slider start at 3.5% discount
    _currentPrice = (_maxPrice * 0.965).roundToDouble();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _discountPercent {
    if (_maxPrice <= 0) return 0.0;
    final diff = _maxPrice - _currentPrice;
    return (diff / _maxPrice) * 100.0;
  }

  double get _discountAmount => _maxPrice - _currentPrice;

  int get _paxCount => widget.quotation.paxCount > 0 ? widget.quotation.paxCount : 1;

  double get _currentPerPersonPrice => _currentPrice / _paxCount;

  Color get _discountColor {
    final pct = _discountPercent;
    if (pct <= 2.0) {
      return const Color(0xFF10B981); // Green (0-2%)
    } else if (pct <= 5.0) {
      return const Color(0xFFF59E0B); // Amber / Yellow (3-5%)
    } else {
      return const Color(0xFFEA580C); // Orange (6-7%)
    }
  }

  String get _discountTierLabel {
    final pct = _discountPercent;
    if (pct <= 2.0) {
      return 'High Operator Acceptance';
    } else if (pct <= 5.0) {
      return 'Moderate Acceptance Chance';
    } else {
      return 'Maximum 7% Limit (Aggressive)';
    }
  }

  Future<void> _handleCounterOfferSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        _currentPrice,
        _currentPerPersonPrice,
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit offer: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Negotiate Price',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.nearBlack,
                    ),
                  ),
                  Text(
                    'Real-Time Operator Counter-Offer Engine',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '$_paxCount Pax Squad',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Price Comparison Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operator Proposed',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₹${_maxPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 36,
                      width: 1,
                      color: AppColors.border,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Your Counter Offer',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _discountColor,
                          ),
                        ),
                        Text(
                          '₹${_currentPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.nearBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 15, color: AppColors.primaryDarkBlue),
                        const SizedBox(width: 4),
                        Text(
                          'Per Person Share:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_currentPerPersonPrice.toStringAsFixed(0)} / person',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 7% Smart Slider Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Requested Discount',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.nearBlack,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _discountColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _discountColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '-${_discountPercent.toStringAsFixed(1)}% (Save ₹${_discountAmount.toStringAsFixed(0)})',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: _discountColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _discountColor,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: _discountColor,
              overlayColor: _discountColor.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _currentPrice,
              min: _minPrice,
              max: _maxPrice,
              divisions: 28,
              onChanged: (val) {
                setState(() {
                  _currentPrice = val.roundToDouble();
                });
              },
            ),
          ),

          // Slider Range Cues
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Max 7% Cap (₹${_minPrice.toStringAsFixed(0)})',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Full Price (₹${_maxPrice.toStringAsFixed(0)})',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Acceptance Chance Feedback Tag
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _discountColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _discountPercent <= 2.0
                      ? Icons.check_circle_rounded
                      : (_discountPercent <= 5.0
                          ? Icons.info_outline_rounded
                          : Icons.warning_amber_rounded),
                  size: 16,
                  color: _discountColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _discountTierLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _discountColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Optional Note to Operator
          TextField(
            controller: _notesController,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Note to Operator (Optional)',
              hintText: 'e.g., We are a college group ready to pay immediately',
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.softGrey,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Submit Counter-Offer Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleCounterOfferSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit Counter-Offer (₹${_currentPrice.toStringAsFixed(0)})',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
