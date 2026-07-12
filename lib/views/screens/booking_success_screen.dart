import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_routes.dart';
import '../../constants/app_colors.dart';
import '../../models/booking.dart';
import '../../utils/app_google_fonts.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/primary_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 38, 22, 28),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 116,
                    height: 116,
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size: 62,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Booking berhasil!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detail booking sudah disimpan dan notifikasi pengingat akan dikirim sebelum jadwal dimulai.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _BookingReceipt(booking: booking),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Kembali ke Home',
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.myBookings,
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Lihat Booking Saya',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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
}

class _BookingReceipt extends StatelessWidget {
  const _BookingReceipt({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          const AppLogo(width: 46, height: 40, radius: 12),
          const SizedBox(height: 14),
          Text(
            booking.roomName,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _ReceiptLine(
            label: 'Tanggal',
            value: DateFormat('EEEE, d MMMM y', 'id_ID').format(booking.date),
          ),
          const SizedBox(height: 10),
          _ReceiptLine(
            label: 'Waktu',
            value: '${booking.startTime} - ${booking.endTime}',
          ),
          const SizedBox(height: 10),
          _ReceiptLine(label: 'Durasi', value: '${booking.durationHours} jam'),
        ],
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
