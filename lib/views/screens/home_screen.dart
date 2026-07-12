import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../models/room.dart';
import '../../utils/app_google_fonts.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/booking_rule_card.dart';
import '../../widgets/room_card.dart';
import '../../widgets/status_card.dart';
import 'room_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomController>().fetchRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        context.watch<AuthController>().currentUser?.name ?? 'Rangga';
    final roomController = context.watch<RoomController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: roomController.fetchRooms,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                children: [
                  _HomeHeader(userName: userName),
                  const SizedBox(height: 14),
                  _SearchBar(
                    controller: _searchController,
                    hasFilters:
                        roomController.searchQuery.isNotEmpty ||
                        roomController.selectedCapacity != null,
                    onChanged: roomController.setSearchQuery,
                    onClear: () {
                      _searchController.clear();
                      roomController.clearFilters();
                    },
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(child: StatusCard()),
                      SizedBox(width: 12),
                      Expanded(child: BookingRuleCard()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CapacityChips(
                    selectedCapacity: roomController.selectedCapacity,
                    onSelected: roomController.setCapacityFilter,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    roomController.searchQuery.isEmpty &&
                            roomController.selectedCapacity == null
                        ? 'Semua ruang tersedia'
                        : 'Hasil pencarian ruangan',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._buildRoomContent(roomController),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavigation(),
    );
  }

  List<Widget> _buildRoomContent(RoomController controller) {
    if (controller.isLoading) {
      return const [AppLoadingSection(label: 'Memuat ruang tersedia...')];
    }
    if (controller.errorMessage != null) {
      return [
        AppFeedbackCard(
          title: 'Ruangan belum dapat dimuat',
          message: controller.errorMessage!,
          actionLabel: 'Coba lagi',
          onAction: controller.fetchRooms,
          icon: Icons.cloud_off_rounded,
        ),
      ];
    }
    if (controller.filteredRooms.isEmpty) {
      return [
        AppFeedbackCard(
          title: 'Ruangan tidak ditemukan',
          message:
              'Ubah kata kunci atau filter kapasitas untuk melihat ruang lain.',
          actionLabel: 'Hapus filter',
          onAction: () {
            _searchController.clear();
            controller.clearFilters();
          },
          icon: Icons.meeting_room_outlined,
        ),
      ];
    }

    return [
      for (final room in controller.filteredRooms) ...[
        RoomCard(room: room, onTap: () => _openRoomDetail(room)),
        const SizedBox(height: 12),
      ],
    ];
  }

  void _openRoomDetail(Room room) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
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
          const AppLogo(),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 22, right: 10),
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
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Cari ruangan atau kapasitas',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.muted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (hasFilters)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Hapus filter',
            ),
        ],
      ),
    );
  }
}

class _CapacityChips extends StatelessWidget {
  const _CapacityChips({
    required this.selectedCapacity,
    required this.onSelected,
  });

  final int? selectedCapacity;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          _CapacityChip(
            label: 'Semua',
            isSelected: selectedCapacity == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          _CapacityChip(
            label: '4 orang',
            isSelected: selectedCapacity == 4,
            isCyan: true,
            onTap: () => onSelected(4),
          ),
          const SizedBox(width: 8),
          _CapacityChip(
            label: '6 orang',
            isSelected: selectedCapacity == 6,
            onTap: () => onSelected(6),
          ),
          const SizedBox(width: 8),
          _CapacityChip(
            label: '8 orang',
            isSelected: selectedCapacity == 8,
            onTap: () => onSelected(8),
          ),
        ],
      ),
    );
  }
}

class _CapacityChip extends StatelessWidget {
  const _CapacityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCyan = false,
  });

  final String label;
  final bool isSelected;
  final bool isCyan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primary
        : isCyan
        ? AppColors.cyanSoft
        : AppColors.card;
    final borderColor = isSelected
        ? AppColors.primary
        : isCyan
        ? AppColors.cyanBorder
        : AppColors.border;
    final textColor = isSelected
        ? Colors.white
        : isCyan
        ? const Color(0xFF0891B2)
        : AppColors.textPrimary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
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
      child: Align(
        alignment: Alignment.bottomCenter,
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
              child: Row(
                children: [
                  const _BottomNavItem(label: 'Home', isActive: true),
                  _BottomNavItem(
                    label: 'Booking',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.myBookings),
                  ),
                  _BottomNavItem(
                    label: 'Profile',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                  ),
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
  const _BottomNavItem({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }
}
