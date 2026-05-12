import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_chronometer_balance/screens/balance_screen.dart';
import 'package:the_chronometer_balance/screens/observatory_map_screen.dart';
import 'package:the_chronometer_balance/screens/stats_screen.dart';
import 'package:the_chronometer_balance/utils/const.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> _screens() => [
        const BalanceScreen(),
        ObservatoryMapScreen(isActive: _currentIndex == 1),
        const StatsScreen(),
      ];

  final List<_TabItem> _tabs = const [
    _TabItem(Icons.balance_rounded, 'Balance'),
    _TabItem(Icons.map_outlined, 'Observatory'),
    _TabItem(Icons.analytics_rounded, 'Stats'),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens()),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 20.h,
            child: _buildGlassNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 72.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: kCardSurface.withAlpha(210),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: kOutline.withAlpha(120), width: 1),
            boxShadow: [
              BoxShadow(
                color: kPrimaryText.withAlpha(18),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final isSelected = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kAccent.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 18.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _tabs[i].icon,
                          color: isSelected ? kAccent : kSecondaryText,
                          size: 20.sp,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 3.w),
                          Text(
                            _tabs[i].label,
                            style: GoogleFonts.ibmPlexMono(
                              color: kAccent,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem(this.icon, this.label);
}
