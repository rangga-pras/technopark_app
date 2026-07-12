import 'package:flutter/material.dart';

import '../../config/booking_rules.dart';
import '../../constants/app_colors.dart';
import '../../models/room.dart';
import '../../utils/app_google_fonts.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/room_thumbnail.dart';
import 'booking_form_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  const RoomDetailScreen({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final facilities = room.facilities.isEmpty
        ? const ['WiFi', 'Monitor', 'Whiteboard']
        : room.facilities;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textPrimary,
                      tooltip: 'Kembali',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Detail Ruangan',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 164,
                  decoration: BoxDecoration(
                    color: room.capacity >= 8
                        ? AppColors.cyanSoft
                        : AppColors.blueSoft,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: 1.65,
                      child: RoomThumbnail(
                        capacity: room.capacity,
                        visualVariant: room.visualVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  room.name,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${room.capacity} orang',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _AvailabilityBadge(isAvailable: room.isAvailable),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoCard(
                  title: 'Tentang ruangan',
                  child: Text(
                    room.description,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Fasilitas',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final facility in facilities)
                        _FacilityChip(facility),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  title: 'Informasi booking',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoLine(
                        icon: Icons.schedule_rounded,
                        text: 'Operasional Senin-Sabtu, 09:00-19:00',
                      ),
                      const SizedBox(height: 10),
                      _InfoLine(
                        icon: Icons.timer_outlined,
                        text:
                            'Durasi booking selalu ${BookingRules.durationHours} jam',
                      ),
                      const SizedBox(height: 10),
                      _InfoLine(
                        icon: Icons.event_busy_outlined,
                        text:
                            'Satu akun hanya dapat booking satu kali per tanggal',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: room.isAvailable
                      ? 'Booking Ruangan'
                      : 'Ruangan Tidak Tersedia',
                  onPressed: room.isAvailable
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingFormScreen(room: room),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cyanSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cyanBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: const Color(0xFF0891B2),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.successSoft : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAvailable
              ? AppColors.successBorder
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Text(
        isAvailable ? 'Tersedia' : 'Penuh',
        style: GoogleFonts.inter(
          color: isAvailable ? AppColors.successDark : const Color(0xFFD97706),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
