import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quotation_model.dart';
import '../services/quotation_negotiation_service.dart';
import '../utils/colors.dart';
import 'confirmed_trip_dashboard_screen.dart';

class QuotationPaymentScreen extends StatefulWidget {
  final QuotationModel quotation;
  final String destination;
  final int paxCount;

  const QuotationPaymentScreen({
    super.key,
    required this.quotation,
    required this.destination,
    required this.paxCount,
  });

  @override
  State<QuotationPaymentScreen> createState() => _QuotationPaymentScreenState();
}

class _QuotationPaymentScreenState extends State<QuotationPaymentScreen> {
  final QuotationNegotiationService _negotiationService =
      QuotationNegotiationService();

  int _selectedPaymentMethod = 0; // 0: UPI, 1: Card, 2: NetBanking
  String _selectedUpiApp = 'Google Pay';
  String _selectedBank = 'HDFC Bank';

  final TextEditingController _upiIdController =
      TextEditingController(text: 'traveler@okaxis');
  final TextEditingController _cardNumberController =
      TextEditingController(text: '4532 •••• •••• 8821');
  final TextEditingController _cardExpiryController =
      TextEditingController(text: '08/29');
  final TextEditingController _cardCvvController =
      TextEditingController(text: '721');

  bool _isProcessing = false;
  String _processingStep = '';
  double _processingProgress = 0.0;

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _processingStep = 'Connecting to Secure Banking Gateway (256-bit SSL)...';
      _processingProgress = 0.25;
    });
    print('💳 [PAYMENT_INIT] Initiating payment verification for quotation ID: "${widget.quotation.id}"');

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _processingStep = 'Verifying Transaction with Bank & Locking Escrow...';
      _processingProgress = 0.65;
    });
    print('💳 [PAYMENT_VERIFY] Bank funds verified. Locking escrow amount: ₹${widget.quotation.totalFinalPrice}');

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _processingStep = 'Securing Itinerary Booking with Local Operator...';
      _processingProgress = 0.90;
    });

    final paymentId = 'PAY_${DateTime.now().millisecondsSinceEpoch}';
    final success = await _negotiationService.markQuotationAsBooked(
      quotationId: widget.quotation.id,
      paymentId: paymentId,
      tripRequestId: widget.quotation.tripRequestId,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _processingProgress = 1.0;
    });

    if (success) {
      print('🎉 [PAYMENT_SUCCESS] Quotation successfully BOOKED in database! Showing confirmation modal.');
      _showBookingSuccessDialog(paymentId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment simulation failed to sync with database. Please retry.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showBookingSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Badge
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trip Booking Confirmed!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.nearBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The custom itinerary is now locked and booked for both your squad and the tour operator.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction & Ref Details
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Payment ID', paymentId),
                      _buildReceiptRow('Quotation Ref', widget.quotation.id.length > 8 ? widget.quotation.id.substring(0, 8) : widget.quotation.id),
                      _buildReceiptRow('Amount Paid', '₹${widget.quotation.totalFinalPrice.toStringAsFixed(0)}'),
                      _buildReceiptRow('Status', 'BOOKED & CONFIRMED', isSuccess: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action: Go to Dashboard
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogCtx); // close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConfirmedTripDashboardScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Open Confirmed Trip Dashboard',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSuccess ? const Color(0xFF059669) : AppColors.nearBlack,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.quotation.totalFinalPrice;
    final ppp = widget.quotation.perPersonPrice;
    final gst = total * 0.05; // 5% GST
    final grandTotal = total + gst;

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
        title: Text(
          'Confirm & Pay',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.nearBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Itinerary Summary Banner ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDarkBlue, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CUSTOM SQUAD TRIP',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.paxCount} Travelers',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.destination,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.quotation.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Per Person Share',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                          Text(
                            '₹${ppp.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFFD400),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Squad Total',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Price Breakdown ───────────────────────────────────────────
            Text(
              'Fare Summary',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildPriceItem('Agreed Itinerary Package', '₹${total.toStringAsFixed(0)}'),
                  _buildPriceItem('Tourism GST (5%)', '₹${gst.toStringAsFixed(0)}'),
                  _buildPriceItem('Platform Concierge Fee', '₹0 (Free Promo)', isDiscount: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.nearBlack,
                        ),
                      ),
                      Text(
                        '₹${grandTotal.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Payment Methods ───────────────────────────────────────────
            Text(
              'Select Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.nearBlack,
              ),
            ),
            const SizedBox(height: 10),

            // Method Selector Tabs
            Row(
              children: [
                _buildMethodTab(0, Icons.qr_code_scanner_rounded, 'UPI Instant'),
                const SizedBox(width: 8),
                _buildMethodTab(1, Icons.credit_card_rounded, 'Card'),
                const SizedBox(width: 8),
                _buildMethodTab(2, Icons.account_balance_rounded, 'NetBanking'),
              ],
            ),

            const SizedBox(height: 14),

            // Payment Details based on selection
            if (_selectedPaymentMethod == 0) _buildUpiSection(),
            if (_selectedPaymentMethod == 1) _buildCardSection(),
            if (_selectedPaymentMethod == 2) _buildNetBankingSection(),

            const SizedBox(height: 20),

            // Trust & Escrow Guarantee Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded,
                      color: Color(0xFF059669), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '100% Escrow Protection: Funds released to operator on milestone fulfillment.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Pay Bar ────────────────────────────────────────────────────
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          child: _isProcessing
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: _processingProgress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: AppColors.primaryDarkBlue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _processingStep,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Pay ₹${grandTotal.toStringAsFixed(0)} & Book Itinerary',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMethodTab(int index, IconData icon, String title) {
    final isSelected = _selectedPaymentMethod == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDarkBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryDarkBlue : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiSection() {
    final apps = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM UPI'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose UPI App',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.nearBlack,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: apps.map((app) {
              final isSel = _selectedUpiApp == app;
              return ChoiceChip(
                label: Text(app),
                selected: isSel,
                onSelected: (val) => setState(() => _selectedUpiApp = app),
                selectedColor: const Color(0xFFEFF6FF),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? AppColors.primaryDarkBlue : AppColors.nearBlack,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _upiIdController,
            decoration: InputDecoration(
              labelText: 'Or enter UPI ID / VPA',
              labelStyle: GoogleFonts.poppins(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              prefixIcon: const Icon(Icons.credit_card_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cardExpiryController,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _cardCvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetBankingSection() {
    final banks = ['HDFC Bank', 'ICICI Bank', 'State Bank of India', 'Axis Bank'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Bank',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.nearBlack,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedBank,
            items: banks
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (val) => setState(() => _selectedBank = val ?? _selectedBank),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDiscount ? const Color(0xFF059669) : AppColors.nearBlack,
            ),
          ),
        ],
      ),
    );
  }
}
