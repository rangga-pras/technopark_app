import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/booking_rules.dart';
import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import '../../utils/app_google_fonts.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/room_thumbnail.dart';
import 'booking_success_screen.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.room});

  final Room room;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingController = context.read<BookingController>();
      bookingController.resetBookingForm();
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        bookingController.fetchUserBookings(user);
      }
    });
  }

  Future<void> _chooseDate(BookingController controller) async {
    final now = DateTime.now();
    final initialDate = _nextSelectableDate(controller, now);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: controller.isDateSelectable,
      helpText: 'Pilih tanggal booking',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (selected != null) {
      controller.setSelectedDate(selected);
    }
  }

  DateTime _nextSelectableDate(BookingController controller, DateTime date) {
    var result = DateTime(date.year, date.month, date.day);
    while (!controller.isDateSelectable(result)) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  Future<void> _submit() async {
    final authController = context.read<AuthController>();
    final bookingController = context.read<BookingController>();
    final user = authController.currentUser;
    if (user == null) {
      return;
    }

    final booking = await bookingController.createBooking(
      user: user,
      room: widget.room,
    );
    if (!mounted || booking == null) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: booking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = context.watch<BookingController>();
    final user = context.watch<AuthController>().currentUser;
    final selectedDate = bookingController.selectedDate;
    final selectedTimeSlot = bookingController.selectedTimeSlot;

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
                      'Form Booking',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SelectedRoomCard(room: widget.room),
                const SizedBox(height: 16),
                Text(
                  'Tanggal penggunaan',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _PickerButton(
                  icon: Icons.calendar_today_rounded,
                  label: selectedDate == null
                      ? 'Pilih tanggal booking'
                      : DateFormat(
                          'EEEE, d MMMM y',
                          'id_ID',
                        ).format(selectedDate),
                  onTap: () => _chooseDate(bookingController),
                ),
                const SizedBox(height: 8),
                Text(
                  'Minggu dan hari libur nasional tidak dapat dipilih.',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Slot waktu',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final slot in BookingRules.timeSlots)
                      _TimeSlotChip(
                        slot: slot,
                        isSelected:
                            selectedTimeSlot?.startTime == slot.startTime,
                        onTap: () =>
                            bookingController.setSelectedTimeSlot(slot),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _DurationCard(),
                const SizedBox(height: 16),
                _BookingSummary(
                  room: widget.room,
                  selectedDate: selectedDate,
                  timeSlot: selectedTimeSlot,
                ),
                if (bookingController.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  AppFeedbackCard(
                    title: 'Periksa booking',
                    message: bookingController.errorMessage!,
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Konfirmasi Booking',
                  onPressed: user == null || bookingController.isSubmitting
                      ? null
                      : _submit,
                  isLoading: bookingController.isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedRoomCard extends StatelessWidget {
  const _SelectedRoomCard({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          RoomThumbnail(
            capacity: room.capacity,
            visualVariant: room.visualVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${room.capacity} orang - Workspace gratis',
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

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 19),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final BookingTimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            slot.label,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cyanSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cyanBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Durasi booking sudah ditetapkan selama 2 jam.',
              style: GoogleFonts.inter(
                color: const Color(0xFF0E7490),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({
    required this.room,
    required this.selectedDate,
    required this.timeSlot,
  });

  final Room room;
  final DateTime? selectedDate;
  final BookingTimeSlot? timeSlot;

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? 'Belum dipilih'
        : DateFormat('d MMMM y', 'id_ID').format(selectedDate!);
    final timeText = timeSlot?.label ?? 'Belum dipilih';

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
            'Ringkasan booking',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryLine(label: 'Ruangan', value: room.name),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Tanggal', value: dateText),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Waktu', value: timeText),
          const SizedBox(height: 8),
          const _SummaryLine(label: 'Durasi', value: '2 jam'),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
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
