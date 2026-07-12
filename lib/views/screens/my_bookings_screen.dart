import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking.dart';
import '../../utils/app_google_fonts.dart';
import '../../widgets/app_feedback.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  BookingCategory _selectedCategory = BookingCategory.upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
  }

  Future<void> _loadBookings() async {
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      await context.read<BookingController>().fetchUserBookings(user);
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan booking?'),
          content: Text(
            'Booking ${booking.roomName} akan dibatalkan dan pengingatnya dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Batalkan'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != true || !mounted) {
      return;
    }

    final bookingController = context.read<BookingController>();
    final isCancelled = await bookingController.cancelBooking(booking);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isCancelled
                ? 'Booking berhasil dibatalkan.'
                : bookingController.errorMessage ??
                      'Booking tidak dapat dibatalkan.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = context.watch<BookingController>();
    final bookings = bookingController.bookingsForCategory(_selectedCategory);

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
                      'Booking Saya',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _CategoryChips(
                  selectedCategory: _selectedCategory,
                  onSelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
                const SizedBox(height: 18),
                if (bookingController.isLoading)
                  const AppLoadingSection(label: 'Memuat booking...')
                else if (bookingController.errorMessage != null)
                  AppFeedbackCard(
                    title: 'Booking belum dapat dimuat',
                    message: bookingController.errorMessage!,
                    actionLabel: 'Coba lagi',
                    onAction: _loadBookings,
                    icon: Icons.cloud_off_rounded,
                  )
                else if (bookings.isEmpty)
                  const AppFeedbackCard(
                    title: 'Belum ada booking',
                    message:
                        'Booking ruangan yang kamu buat akan muncul di sini.',
                    icon: Icons.event_note_outlined,
                  )
                else
                  for (final booking in bookings) ...[
                    _BookingCard(
                      booking: booking,
                      canCancel: bookingController.canCancel(booking),
                      isSubmitting: bookingController.isSubmitting,
                      onCancel: () => _cancelBooking(booking),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selectedCategory,
    required this.onSelected,
  });

  final BookingCategory selectedCategory;
  final ValueChanged<BookingCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          _CategoryChip(
            label: 'Mendatang',
            isSelected: selectedCategory == BookingCategory.upcoming,
            onTap: () => onSelected(BookingCategory.upcoming),
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            label: 'Selesai',
            isSelected: selectedCategory == BookingCategory.completed,
            onTap: () => onSelected(BookingCategory.completed),
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            label: 'Dibatalkan',
            isSelected: selectedCategory == BookingCategory.cancelled,
            onTap: () => onSelected(BookingCategory.cancelled),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.canCancel,
    required this.isSubmitting,
    required this.onCancel,
  });

  final Booking booking;
  final bool canCancel;
  final bool isSubmitting;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(booking);

    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          _BookingInfoLine(
            icon: Icons.calendar_today_rounded,
            value: DateFormat('EEEE, d MMMM y', 'id_ID').format(booking.date),
          ),
          const SizedBox(height: 8),
          _BookingInfoLine(
            icon: Icons.schedule_rounded,
            value: '${booking.startTime} - ${booking.endTime} (2 jam)',
          ),
          if (canCancel) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isSubmitting ? null : onCancel,
                child: Text(
                  'Batalkan booking',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(Booking booking) {
    final isCancelled =
        booking.status == 'cancelled' || booking.status == 'canceled';
    final isCompleted =
        booking.status == 'completed' ||
        DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
        ).isBefore(DateTime.now());

    if (isCancelled) {
      return const _StatusInfo(
        label: 'Dibatalkan',
        background: Color(0xFFFEF2F2),
        border: Color(0xFFFECACA),
        text: Color(0xFFDC2626),
      );
    }
    if (isCompleted) {
      return const _StatusInfo(
        label: 'Selesai',
        background: Color(0xFFF1F5F9),
        border: Color(0xFFE2E8F0),
        text: Color(0xFF64748B),
      );
    }
    return const _StatusInfo(
      label: 'Mendatang',
      background: AppColors.successSoft,
      border: AppColors.successBorder,
      text: AppColors.successDark,
    );
  }
}

class _BookingInfoLine extends StatelessWidget {
  const _BookingInfoLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.background,
    required this.border,
    required this.text,
  });

  final String label;
  final Color background;
  final Color border;
  final Color text;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _StatusInfo status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: status.border),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          color: status.text,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
