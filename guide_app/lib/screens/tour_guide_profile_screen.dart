import 'package:flutter/material.dart';

class TourGuideProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const TourGuideProfileScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<TourGuideProfileScreen> createState() => _TourGuideProfileScreenState();
}

class _TourGuideProfileScreenState extends State<TourGuideProfileScreen> {
  bool _isAvailable = true;

  final String _guideName = 'Captain Ryan Vance';
  final String _guideSubtitle = 'Master Heritage & Coastal Guide';
  final String _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80';

  // Account details
  String _govtId = 'MH-2024-8842';
  String _phone = '+91 98765 43210';
  String _email = 'ryan.vance@guide.in';
  String _payoutMethod = 'UPI: ryan.vance@okhdfcbank';

  void _showEditAccountDetailsDialog() {
    final govtIdCtrl = TextEditingController(text: _govtId);
    final phoneCtrl = TextEditingController(text: _phone);
    final emailCtrl = TextEditingController(text: _email);
    final payoutCtrl = TextEditingController(text: _payoutMethod);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Color(0xFF0F4C5C)),
            SizedBox(width: 8),
            Text(
              'Edit Account Details',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: govtIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Govt Guide ID',
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: payoutCtrl,
                decoration: const InputDecoration(
                  labelText: 'Payout Method',
                  prefixIcon: Icon(Icons.payment_rounded, size: 20),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _govtId = govtIdCtrl.text.trim();
                _phone = phoneCtrl.text.trim();
                _email = emailCtrl.text.trim();
                _payoutMethod = payoutCtrl.text.trim();
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account details updated successfully!'),
                  backgroundColor: Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPreviewPublicProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Public Traveler View',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This is how tourists and travelers see your profile when booking.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 28),
            Expanded(
              child: ListView(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(_avatarUrl),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _guideName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Center(
                    child: Text(
                      '⭐ 4.96 • 142 Verified Tours • Mumbai Heritage Tours',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F4C5C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '10-year South Mumbai native specializing in colonial architecture, Victorian Gothic heritage, and Arabian Sea sunset expeditions. Certified by Maharashtra Tourism Development Corporation.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF334155),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Main Identity Card (No Top AppBar duplicate)
              _buildMainIdentityCard(),
              const SizedBox(height: 16),

              // 2. Agency Affiliation Banner
              _buildAgencyBanner(),
              const SizedBox(height: 20),

              // 3. Performance & Earnings Grid (2x2)
              _buildPerformanceHubSection(),
              const SizedBox(height: 20),

              // 4. Account & Contact Details
              _buildAccountDetailsCard(),
              const SizedBox(height: 20),

              // 5. Public Bio & Credentials (Traveler Preview)
              _buildTravelerPreviewSection(),
              const SizedBox(height: 20),

              // 6. Utilities & Exit
              _buildUtilitiesSection(),
              const SizedBox(height: 24),

              // Sign Out Button
              _buildSignOutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. MAIN IDENTITY CARD
  // ==========================================
  Widget _buildMainIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Center large CircleAvatar (radius 50)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0F4C5C), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE6F4F6),
              backgroundImage: NetworkImage(_avatarUrl),
            ),
          ),
          const SizedBox(height: 14),

          // Guide's Name (bold size 22)
          Text(
            _guideName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle in Dark Teal
          Text(
            _guideSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F4C5C),
            ),
          ),
          const SizedBox(height: 16),

          // Availability Toggle: Centered Pill-shaped Switch
          InkWell(
            onTap: () => setState(() => _isAvailable = !_isAvailable),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isAvailable
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isAvailable
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFFFECACA),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAvailable
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAvailable ? 'Status: Available' : 'Status: Busy',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _isAvailable
                          ? const Color(0xFF065F46)
                          : const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 22,
                    width: 34,
                    child: Switch(
                      value: _isAvailable,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: const Color(0xFF10B981),
                      inactiveThumbColor: const Color(0xFFEF4444),
                      activeTrackColor: const Color(0xFFA7F3D0),
                      inactiveTrackColor: const Color(0xFFFECACA),
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. AGENCY AFFILIATION BANNER
  // ==========================================
  Widget _buildAgencyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB2DFDB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C5C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mumbai Heritage Tours',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F4C5C),
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified Agency Partner',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. PERFORMANCE & EARNINGS GRID (2x2)
  // ==========================================
  Widget _buildPerformanceHubSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Hub',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Earned',
                value: '₹1,85,000',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Tours Completed',
                value: '142',
                icon: Icons.tour_rounded,
                iconColor: const Color(0xFF0F4C5C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: '5-Star Rating',
                value: '99%',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Repeat Squads',
                value: '28',
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFFE36414),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. ACCOUNT & CONTACT DETAILS
  // ==========================================
  Widget _buildAccountDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: Color(0xFF0F4C5C),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _showEditAccountDetailsDialog,
                tooltip: 'Edit details',
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildAccountDetailRow(
            icon: Icons.badge_outlined,
            label: 'Govt Guide ID',
            value: _govtId,
          ),
          const Divider(height: 20),
          _buildAccountDetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: _phone,
          ),
          const Divider(height: 20),
          _buildAccountDetailRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: _email,
          ),
          const Divider(height: 20),
          _buildAccountDetailRow(
            icon: Icons.payment_rounded,
            label: 'Payout Method',
            value: _payoutMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. PUBLIC BIO & CREDENTIALS (Traveler Preview)
  // ==========================================
  Widget _buildTravelerPreviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Traveler Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          // About Me
          const Text(
            '10-year South Mumbai native specializing in colonial architecture, Victorian Gothic heritage, and Arabian Sea sunset expeditions.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Languages Wrap
          const Text(
            'Spoken Languages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildLanguageChip('English (Native)'),
              _buildLanguageChip('Hindi (Fluent)'),
              _buildLanguageChip('Marathi'),
            ],
          ),
          const SizedBox(height: 14),

          // Specialties Checklist
          const Text(
            'Specialties & Certifications',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          _buildSpecialtyItem('Heritage Architecture Walks'),
          const SizedBox(height: 6),
          _buildSpecialtyItem('Coastal Expeditions'),
          const SizedBox(height: 6),
          _buildSpecialtyItem('Wilderness First Aid (CPR)'),

          const SizedBox(height: 18),

          // Centered OutlinedButton
          Center(
            child: OutlinedButton.icon(
              onPressed: _showPreviewPublicProfileModal,
              icon: const Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Color(0xFF0F4C5C),
              ),
              label: const Text(
                'Preview Public Profile',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F4C5C),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0F4C5C)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildSpecialtyItem(String title) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 6. UTILITIES SECTION
  // ==========================================
  Widget _buildUtilitiesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF0F4C5C),
                size: 20,
              ),
            ),
            title: const Text(
              'Calendar & Blackout Dates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calendar & blackout schedule opened.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ),
            title: const Text(
              'Past Tour Logs & Reviews',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Past 142 tour logs & reviews loaded.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIGN OUT BUTTON
  // ==========================================
  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(
          'Sign Out of Guide Portal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () {
          if (widget.onLogout != null) {
            widget.onLogout!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
    );
  }
}
