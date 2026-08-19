import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/booking_model.dart';
import 'booking_controller.dart';
import 'booking_qr_modal.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(myBookingsProvider),
          ),
        ],
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
              const SizedBox(height: 12),
              Text(err.toString().replaceAll('Exception: ', '')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(myBookingsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes reservaciones activas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explora nuestro catálogo y reserva tu habitación favorita',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  return _buildBookingCard(context, b, dateFormat, isDesktop);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel b, DateFormat df, bool isDesktop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Code, Badge, QR Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.bookingCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      'Habitación ${b.roomNumber} (${b.roomTitle})',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    StatusBadge(status: b.status),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.qr_code, color: AppTheme.primaryBlue),
                      tooltip: 'Ver Código QR',
                      onPressed: () => BookingQrModal.show(context, b),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // Middle Grid: Dates & Guests
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildInfoItem(Icons.login, 'Entrada', df.format(b.checkInDate)),
                _buildInfoItem(Icons.logout, 'Salida', df.format(b.checkOutDate)),
                _buildInfoItem(Icons.nightlight_outlined, 'Noches', '${b.totalNights} noche(s)'),
                _buildInfoItem(Icons.people_outline, 'Huéspedes', '${b.guestsCount} pers.'),
              ],
            ),
            const Divider(height: 24),

            // Bottom Row: Price & Payment Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Importe Total:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    Text(
                      CurrencyFormatter.formatDual(b.totalAmountUsd, b.exchangeRateUsed),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => BookingQrModal.show(context, b),
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Ver Comprobante'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryTeal),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
