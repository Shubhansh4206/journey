import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_city_catalog.dart';
import '../screens/group_picker_sheet.dart';
import '../screens/solo_matches_screen.dart';
import '../services/ai_community_service.dart';
import '../services/supabase_service.dart';
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
  late CityCatalog _currentCity;
  bool _loadingInventory = true;
  bool _hasLiveOperatorData = false;

  final Set<String> _selectedIds = {};
  final TextEditingController _budgetController =
      TextEditingController(text: '15000');
  DateTime _startDate = DateTime.now().add(const Duration(days: 21));
  DateTime _endDate = DateTime.now().add(const Duration(days: 25));
  SelectedGroup? _selectedGroup;
  bool _showSummary = false;
  bool _submitting = false;

  // Swiggy style category filters
  String _selectedCategory = 'All'; // 'All', 'Hotels', 'Activities', 'Places', 'Transport'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentCity = widget.city;
    _fetchLiveInventory();
  }

  Future<void> _fetchLiveInventory() async {
    try {
      final inventory =
          await SupabaseService().fetchInventoryForCity(widget.city.name);

      final dbHotels = inventory['hotels'] ?? [];
      final dbActivities = inventory['activities'] ?? [];
      final dbPlaces = inventory['places'] ?? [];
      final dbTransport = inventory['transport'] ?? [];

      final hasData = dbHotels.isNotEmpty ||
          dbActivities.isNotEmpty ||
          dbPlaces.isNotEmpty ||
          dbTransport.isNotEmpty;

      if (mounted) {
        setState(() {
          _currentCity = _currentCity.copyWith(
            hotels: dbHotels,
            activities: dbActivities,
            places: dbPlaces,
            transport: dbTransport,
          );
          _hasLiveOperatorData = hasData;
          _loadingInventory = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading operator inventory: $e');
      if (mounted) {
        setState(() => _loadingInventory = false);
      }
    }
  }

  List<CatalogItem> get _allItems => [
        ..._currentCity.hotels,
        ..._currentCity.activities,
        ..._currentCity.places,
        ..._currentCity.transport,
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
      city: _currentCity,
      items: _selectedItems,
      budget: _budget,
      startDate: _startDate,
      endDate: _endDate,
      isSolo: widget.isSolo,
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtShort(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFC8019), // Swiggy Orange
              onPrimary: Colors.white,
              onSurface: AppColors.darkCharcoal,
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _pinAsSoloPostIt() async {
    if (!_canContinue) return;
    await AiCommunityService().saveTripPostIt(_draft());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📌 Pinned as Solo Post-It! Our AI is clustering you with compatible travelers.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF8B5CF6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _onPrimaryCta() async {
    if (!_canContinue) return;
    if (widget.isSolo) {
      // Auto-record post-it draft for AI aggregation
      AiCommunityService().saveTripPostIt(_draft());

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
        SnackBar(
          content: Text(
            'Could not submit trip. Try again.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Trip request for ${widget.city.name} sent to local operators!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF60B246),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showSummary
                      ? _buildSummaryContent()
                      : _buildBuilderContent(),
                ),
              ),
              // Bottom padding so content is not obscured by the floating cart bar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildSwiggyFloatingCartBar(),
        ],
      ),
    );
  }

  // ── Swiggy Hero Sliver AppBar ──────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1E2430),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            if (_showSummary) {
              setState(() => _showSummary = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing itinerary link...'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: _showSummary
            ? Text(
                'Checkout Summary',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.city.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          shadows: [
                            const Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF60B246),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              '4.9',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.city.tagline,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.city.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: widget.city.accent,
                child: const Center(
                  child: Icon(Icons.landscape, size: 64, color: Colors.white54),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 70,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isSolo
                      ? AppColors.punchPink
                      : const Color(0xFFFC8019),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSolo ? Icons.person : Icons.groups,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isSolo ? 'Solo Mode' : 'Group Squad',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Itinerary Builder View ───────────────────────────────────────────
  Widget _buildBuilderContent() {
    return Column(
      key: const ValueKey('builder'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildTripConfiguratorCard(),
        const SizedBox(height: 16),
        _buildSwiggyPromoBanner(),
        const SizedBox(height: 16),
        _buildCategoryTabs(),
        const SizedBox(height: 12),
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildCatalogList(),
      ],
    );
  }

  // ── Swiggy Delivery / Trip Configurator Header Card ──────────────────────
  Widget _buildTripConfiguratorCard() {
    final days = _endDate.difference(_startDate).inDays;
    final overBudget = _budget > 0 && _estimated > _budget;
    final pct = _budget > 0 ? (_estimated / _budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_calendar_rounded,
                  color: Color(0xFFFC8019),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRIP PREFERENCES',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFC8019),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Dates & Per-Person Budget',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // Date Pickers Row
          Row(
            children: [
              Expanded(
                child: _buildDateTile('DEPARTURE', _startDate, true),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$days ${days == 1 ? 'Night' : 'Nights'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: _buildDateTile('RETURN', _endDate, false),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Budget Input & Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Budget per person',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  _presetBudgetChip(10000),
                  const SizedBox(width: 4),
                  _presetBudgetChip(15000),
                  const SizedBox(width: 4),
                  _presetBudgetChip(25000),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.darkCharcoal,
            ),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 8, top: 12, bottom: 12),
                child: Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFC8019),
                  ),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixText: 'INR',
              suffixStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFC8019), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Swiggy Budget Meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart Estimate: ₹${_estimated.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: overBudget ? AppColors.danger : AppColors.darkCharcoal,
                    ),
                  ),
                  Text(
                    overBudget
                        ? 'Over cap by ₹${(_estimated - _budget).toStringAsFixed(0)}'
                        : '${((1 - pct) * 100).toStringAsFixed(0)}% remaining',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: overBudget ? AppColors.danger : const Color(0xFF60B246),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: overBudget
                      ? AppColors.danger
                      : (pct > 0.8
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF60B246)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime date, bool isStart) {
    return InkWell(
      onTap: () => _pickDate(isStart: isStart),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFFFC8019)),
                const SizedBox(width: 4),
                Text(
                  _fmtShort(date),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetBudgetChip(double value) {
    final isSelected = _budget == value;
    return InkWell(
      onTap: () {
        setState(() {
          _budgetController.text = value.toStringAsFixed(0);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFC8019) : Colors.transparent,
          ),
        ),
        child: Text(
          '₹${(value / 1000).toStringAsFixed(0)}k',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFFFC8019) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Swiggy Promo Banner ───────────────────────────────────────────────────
  Widget _buildSwiggyPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _hasLiveOperatorData
              ? [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)]
              : [const Color(0xFFFFF7ED), const Color(0xFFFFF1F2)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasLiveOperatorData
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFFEDD5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _hasLiveOperatorData
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFFC8019),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _hasLiveOperatorData
                  ? Icons.bolt_rounded
                  : Icons.local_offer,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasLiveOperatorData
                      ? '⚡ LIVE OPERATOR INVENTORY'
                      : 'MUST-HAVES PACK DISCOUNT',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _hasLiveOperatorData
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFFC8019),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _hasLiveOperatorData
                      ? 'Showing real-time stays, activities, places & transport from verified operators.'
                      : 'Add 1 Stay + 2 Activities to unlock up to 20% operator discounts!',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Swiggy Category Tabs ──────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    final categories = [
      {'name': 'All', 'icon': Icons.space_dashboard_outlined, 'count': _allItems.length},
      {'name': 'Hotels', 'icon': Icons.hotel_outlined, 'count': _currentCity.hotels.length},
      {'name': 'Activities', 'icon': Icons.hiking, 'count': _currentCity.activities.length},
      {'name': 'Places', 'icon': Icons.place_outlined, 'count': _currentCity.places.length},
      {'name': 'Transport', 'icon': Icons.directions_car_rounded, 'count': _currentCity.transport.length},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final count = cat['count'] as int;
          final isSelected = _selectedCategory == name;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = name),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E2430) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E2430)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? const Color(0xFFFC8019) : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFC8019)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Swiggy Search Bar ─────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search stays, activities, places, rides...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFC8019), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFC8019)),
          ),
        ),
      ),
    );
  }

  // ── Swiggy Catalog List View ──────────────────────────────────────────────
  Widget _buildCatalogList() {
    if (_loadingInventory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFC8019),
          ),
        ),
      );
    }

    if (_allItems.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.travel_explore_outlined,
                size: 48, color: Color(0xFFFC8019)),
            const SizedBox(height: 12),
            Text(
              'No Operator Packages Found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Local tour operators have not listed inventory for ${_currentCity.name} in the database yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final categoryItems = _selectedCategory == 'Hotels'
        ? _currentCity.hotels
        : (_selectedCategory == 'Activities'
            ? _currentCity.activities
            : (_selectedCategory == 'Places'
                ? _currentCity.places
                : (_selectedCategory == 'Transport'
                    ? _currentCity.transport
                    : _allItems)));

    if (_selectedCategory != 'All' && categoryItems.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No $_selectedCategory Listed',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No $_selectedCategory currently in database for ${_currentCity.name}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_selectedCategory == 'All' || _selectedCategory == 'Hotels')
          _buildSwiggySection('Hotels & Stays', _currentCity.hotels, Icons.hotel_rounded, const Color(0xFF2373F4)),
        if (_selectedCategory == 'All' || _selectedCategory == 'Activities')
          _buildSwiggySection('Activities & Thrills', _currentCity.activities, Icons.hiking, const Color(0xFF9564DD)),
        if (_selectedCategory == 'All' || _selectedCategory == 'Places')
          _buildSwiggySection('Must-Visit Attractions', _currentCity.places, Icons.place_rounded, const Color(0xFFFF0052)),
        if (_selectedCategory == 'All' || _selectedCategory == 'Transport')
          _buildSwiggySection('Transport & Transfers', _currentCity.transport, Icons.directions_car_rounded, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildSwiggySection(
      String title, List<CatalogItem> items, IconData icon, Color color) {
    final filtered = items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery) ||
          item.subtitle.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${filtered.length})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = filtered[index];
            return _buildSwiggyDishCard(item, icon, color);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Swiggy Dish / Item Card Component ─────────────────────────────────────
  Widget _buildSwiggyDishCard(CatalogItem item, IconData icon, Color accentColor) {
    final isSelected = _selectedIds.contains(item.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF60B246)
              : const Color(0xFFEEF2F6),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF60B246).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category / Special Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (item.price > 3000 || item.price == 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.price == 0 ? '✨ FREE ENTRY' : '🔥 POPULAR',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFC8019),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFB300)),
                      const SizedBox(width: 2),
                      Text(
                        '4.8',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.price == 0
                        ? 'FREE ENTRY'
                        : '₹${item.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Thumbnail & Swiggy ADD button
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.15),
                        accentColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 40,
                      color: accentColor,
                    ),
                  ),
                ),

                // Swiggy Style ADD Button
                Positioned(
                  bottom: -10,
                  left: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(item.id);
                        } else {
                          _selectedIds.add(item.id);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF60B246)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF60B246)
                              : const Color(0xFF60B246),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF60B246).withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isSelected ? 'ADDED' : 'ADD',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF60B246),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              isSelected ? Icons.check : Icons.add,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF60B246),
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
      ),
    );
  }

  // ── Checkout Summary Page View ─────────────────────────────────────────────
  Widget _buildSummaryContent() {
    final group = _selectedGroup;
    final overBudget = _budget > 0 && _estimated > _budget;

    return Column(
      key: const ValueKey('summary'),
      children: [
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF60B246), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'TRIP SUMMARY & QUOTE REQUEST',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              _summaryRow('Destination', widget.city.name),
              _summaryRow('Trip Mode', widget.isSolo ? 'Solo Journey' : 'Group Squad'),
              if (group != null) _summaryRow('Assigned Group', group.name),
              _summaryRow('Travel Dates', '${_fmt(_startDate)} → ${_fmt(_endDate)}'),
              _summaryRow('Per Person Budget', '₹${_budget.toStringAsFixed(0)}'),

              const SizedBox(height: 16),
              Text(
                'Itemized Itinerary (${_selectedItems.length} items)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),

              ..._selectedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '• ${item.name}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        item.price == 0 ? 'FREE' : '₹${item.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Mock Total',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_estimated.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: overBudget ? AppColors.danger : const Color(0xFF60B246),
                    ),
                  ),
                ],
              ),
              if (overBudget)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '⚠️ Total exceeds per-person budget. Local operators will customize quotes to match your ₹${_budget.toStringAsFixed(0)} cap.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.danger,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Swiggy Trust Shield Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '100% OPERATOR GUARANTEE',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    Text(
                      'Verified local trip operators will send customized packages within 24 hours.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Swiggy Bottom Floating Cart Bar ───────────────────────────────────────
  Widget _buildSwiggyFloatingCartBar() {
    final overBudget = _budget > 0 && _estimated > _budget;

    return Positioned(
      bottom: 16 + MediaQuery.of(context).padding.bottom,
      left: 16,
      right: 16,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E2430),
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Left side info
              Expanded(
                child: InkWell(
                  onTap: _selectedItems.isEmpty ? null : _showCartDetailsSheet,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_selectedItems.length} ${_selectedItems.length == 1 ? 'ITEM' : 'ITEMS'} ADDED',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFC8019),
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (_selectedItems.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_up,
                                color: Color(0xFFFC8019), size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Est. ₹${_estimated.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: overBudget ? AppColors.danger : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '/ person',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Right side CTA button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isSolo && !_showSummary) ...[
                    Container(
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF8B5CF6)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.push_pin_rounded,
                            color: Color(0xFFA78BFA), size: 20),
                        tooltip: 'Pin as Solo Post-It',
                        onPressed: _canContinue ? _pinAsSoloPostIt : null,
                      ),
                    ),
                  ],
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: !_canContinue || _submitting
                          ? null
                          : (_showSummary ? _submit : _onPrimaryCta),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFC8019),
                        disabledBackgroundColor: Colors.white24,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFFC8019).withValues(alpha: 0.5),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  _showSummary
                                      ? 'SUBMIT TRIP'
                                      : (widget.isSolo
                                          ? 'FIND MATCHES'
                                          : 'CHOOSE GROUP'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cart Details Bottom Sheet Drawer ─────────────────────────────────────
  void _showCartDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Itinerary Items',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedIds.clear());
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.poppins(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = _selectedItems[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            item.type.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.price == 0
                                    ? 'FREE'
                                    : '₹${item.price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: AppColors.danger, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedIds.remove(item.id);
                                  });
                                  setSheetState(() {});
                                  if (_selectedItems.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Estimated Cost',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '₹${_estimated.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: const Color(0xFFFC8019),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
