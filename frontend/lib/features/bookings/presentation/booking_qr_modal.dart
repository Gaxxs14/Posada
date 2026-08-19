import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/booking_model.dart';

class BookingQrModal extends StatelessWidget {
  final BookingModel booking;

  const BookingQrModal({super.key, required this.booking});

  static void show(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingQrModal(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Comprobante de Reservación',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Presenta este código QR en recepción para Check-in ágil',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // QR Code Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryBlue.withAlpha(40), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withAlpha(15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: booking.bookingCode,
              version: QrVersions.auto,
              size: 180,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppTheme.primaryBlue,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            booking.bookingCode,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          StatusBadge(status: booking.status),
          const SizedBox(height: 24),

          // Booking Details Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildRow('Habitación:', '${booking.roomNumber} - ${booking.roomTitle}'),
                const Divider(height: 16),
                _buildRow('Entrada:', dateFormat.format(booking.checkInDate)),
                const Divider(height: 16),
                _buildRow('Salida:', dateFormat.format(booking.checkOutDate)),
                const Divider(height: 16),
                _buildRow('Huéspedes:', '${booking.guestsCount} persona(s) (${booking.totalNights} noches)'),
                const Divider(height: 16),
                _buildRow(
                  'Total a Pagar:',
                  CurrencyFormatter.formatDual(booking.totalAmountUsd, booking.exchangeRateUsed),
                  isBold: true,
                  valueColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Cerrar Comprobante'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 14 : 13,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
