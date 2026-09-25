import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_city_catalog.dart';
import '../screens/group_picker_sheet.dart';
import '../screens/solo_matches_screen.dart';
import '../services/trip_request_service.dart';
import '../utils/colors.dart';

class ItineraryCartScreen extends StatefulWidget {
  final CityCatalog city;
  final bool isSolo;

  const ItineraryCartScreen({
    super.key,
    required this.city,
    required this.isSolo,
  });

  @override
  State<ItineraryCartScreen> createState() => _ItineraryCartScreenState();
}

class _ItineraryCartScreenState extends State<ItineraryCartScreen> {
  final Set<String> _selectedIds = {};
  final TextEditingController _budgetController =
      TextEditingController(text: '15000');
  DateTime _startDate = DateTime.now().add(const Duration(days: 21));
  DateTime _endDate = DateTime.now().add(const Duration(days: 25));
  SelectedGroup? _selectedGroup;
  bool _showSummary = false;
  bool _submitting = false;

  List<CatalogItem> get _allItems => [
        ...widget.city.hotels,
        ...widget.city.activities,
        ...widget.city.places,
      ];

  List<CatalogItem> get _selectedItems =>
      _allItems.where((item) => _selectedIds.contains(item.id)).toList();

  double get _estimated =>
      _selectedItems.fold(0, (sum, item) => sum + item.price);

  double get _budget {
    return double.tryParse(_budgetController.text.trim()) ?? 0;
  }

  bool get _canContinue =>
      _selectedItems.isNotEmpty &&
      _budget > 0 &&
      !_endDate.isBefore(_startDate);

  TripCartDraft _draft() {
    return TripCartDraft(
      city: widget.city,
      items: _selectedItems,
      budget: _budget,
      startDate: _startDate,
      endDate: _endDate,
      isSolo: widget.isSolo,
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 3));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _onPrimaryCta() async {
    if (!_canContinue) return;
    if (widget.isSolo) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SoloMatchesScreen(draft: _draft()),
        ),
      );
      return;
    }

    final group = await showModalBottomSheet<SelectedGroup>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GroupPickerSheet(),
    );
    if (group == null) return;
    setState(() {
      _selectedGroup = group;
      _showSummary = true;
    });
  }

  Future<void> _submit() async {
    final group = _selectedGroup;
    if (group == null) return;
    setState(() => _submitting = true);
    final created = await TripRequestService().create(
      groupId: group.id,
      draft: _draft(),
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit trip. Try again.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip for ${widget.city.name} sent to operators'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
        title: Text(
          _showSummary ? 'Trip summary' : widget.city.name,
          style: GoogleFonts.poppins(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showSummary) {
              setState(() => _showSummary = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _showSummary ? _summaryBody() : _builderBody(),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _builderBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(
          widget.city.tagline,
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _dateChip('Start', _startDate, () => _pickDate(isStart: true))),
            const SizedBox(width: 12),
            Expanded(child: _dateChip('End', _endDate, () => _pickDate(isStart: false))),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Budget per person (₹)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixText: '₹ ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _section('Hotels', widget.city.hotels, Icons.hotel_outlined),
        _section('Activities', widget.city.activities, Icons.hiking),
        _section('Places to visit', widget.city.places, Icons.place_outlined),
      ],
    );
  }

  Widget _dateChip(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _fmt(date),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<CatalogItem> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          final selected = _selectedIds.contains(item.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.electricBlue : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Icon(icon, color: AppColors.electricBlue),
              title: Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                item.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.price == 0
                        ? 'Free'
                        : '₹${item.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    selected ? 'Added' : 'Add',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: selected
                          ? AppColors.success
                          : AppColors.electricBlue,
                    ),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedIds.remove(item.id);
                  } else {
                    _selectedIds.add(item.id);
                  }
                });
              },
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _summaryBody() {
    final group = _selectedGroup;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        _summaryCard(
          title: 'Destination',
          child: Text(
            widget.city.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        _summaryCard(
          title: 'Group (address)',
          child: Text(
            group?.name ?? '-',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        _summaryCard(
          title: 'Dates',
          child: Text(
            '${_fmt(_startDate)} → ${_fmt(_endDate)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        _summaryCard(
          title: 'Budget / pax',
          child: Text(
            '₹${_budget.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          'Itinerary cart',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._selectedItems.map(
          (item) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(item.name, style: GoogleFonts.poppins(fontSize: 14)),
            trailing: Text(
              item.price == 0 ? 'Free' : '₹${item.price.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Est. mock total', style: GoogleFonts.poppins()),
            Text(
              '₹${_estimated.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final overBudget = _budget > 0 && _estimated > _budget;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${_selectedItems.length} items',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                'Est. ₹${_estimated.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: overBudget ? AppColors.danger : AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          if (overBudget)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Over budget — operators will still quote against your cap.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.danger,
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: !_canContinue || _submitting
                  ? null
                  : (_showSummary ? _submit : _onPrimaryCta),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantPurple,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _showSummary
                          ? 'Submit trip'
                          : (widget.isSolo
                              ? 'Find matches'
                              : 'Choose group to continue'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
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
