import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/colors.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    index: 0,
                    label: 'Home',
                    currentIndex: navigationShell.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Icons.explore_rounded,
                    index: 1,
                    label: 'Packages',
                    currentIndex: navigationShell.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Icons.groups_rounded,
                    index: 2,
                    label: 'Solo Comm',
                    currentIndex: navigationShell.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    index: 3,
                    label: 'Profile',
                    currentIndex: navigationShell.currentIndex,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.electricBlue : Colors.grey.shade400,
              size: 28,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.vibrantPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
            ]
          ],
        ),
      ),
    );
  }
}
