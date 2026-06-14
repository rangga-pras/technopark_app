import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../data/room_data.dart';
import '../services/auth_service.dart';
import '../utils/app_google_fonts.dart';
import '../widgets/booking_rule_card.dart';
import '../widgets/room_card.dart';
import '../widgets/status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.instance.currentUser?.name ?? 'Rangga';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              children: [
                _HomeHeader(userName: userName),
                const SizedBox(height: 14),
                const _SearchBar(),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(child: StatusCard()),
                    SizedBox(width: 12),
                    Expanded(child: BookingRuleCard()),
                  ],
                ),
                const SizedBox(height: 14),
                const _CapacityChips(),
                const SizedBox(height: 14),
                Text(
                  'Semua ruang tersedia',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                for (final room in rooms) ...[
                  RoomCard(
                    room: room,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Booking feature is available in the next version.',
                            ),
                          ),
                        );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavigation(),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const _LogoMark(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $userName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mau booking ruang apa hari ini?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          'T',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            'Search',
            style: GoogleFonts.inter(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cari ruangan atau kapasitas',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityChips extends StatelessWidget {
  const _CapacityChips();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: const [
          _CapacityChip(label: 'Semua', isPrimary: true),
          SizedBox(width: 8),
          _CapacityChip(label: '4 orang', isCyan: true),
          SizedBox(width: 8),
          _CapacityChip(label: '6 orang'),
          SizedBox(width: 8),
          _CapacityChip(label: '8 orang'),
        ],
      ),
    );
  }
}

class _CapacityChip extends StatelessWidget {
  const _CapacityChip({
    required this.label,
    this.isPrimary = false,
    this.isCyan = false,
  });

  final String label;
  final bool isPrimary;
  final bool isCyan;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary
        ? AppColors.primary
        : isCyan
        ? AppColors.cyanSoft
        : AppColors.card;
    final borderColor = isPrimary
        ? AppColors.primary
        : isCyan
        ? AppColors.cyanBorder
        : AppColors.border;
    final textColor = isPrimary
        ? Colors.white
        : isCyan
        ? const Color(0xFF0891B2)
        : AppColors.textPrimary;

    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BottomNavItem(label: 'Home', isActive: true),
                  _BottomNavItem(label: 'Booking'),
                  _BottomNavItem(label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? AppColors.primary : AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
