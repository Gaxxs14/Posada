import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bookings/data/booking_repository.dart';
import '../../bookings/models/booking_model.dart';
import '../../bookings/presentation/booking_controller.dart';
import '../../rooms/presentation/room_controller.dart';

class ReceptionScreen extends ConsumerStatefulWidget {
  const ReceptionScreen({super.key});

  @override
  ConsumerState<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends ConsumerState<ReceptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _approveBooking(String id) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.updateStatus(id, 'Confirmed');
      ref.invalidate(allBookingsProvider);
      ref.invalidate(roomsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservación confirmada exitosamente.'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _checkIn(String id) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.checkIn(id);
      ref.invalidate(allBookingsProvider);
      ref.invalidate(roomsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in realizado. Huésped registrado en habitación.'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _checkOut(String id) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.checkOut(id);
      ref.invalidate(allBookingsProvider);
      ref.invalidate(roomsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-out completado. Habitación enviada a limpieza.'), backgroundColor: AppTheme.primaryNavy),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(allBookingsProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: Text('Control de Recepción & Huéspedes', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(allBookingsProvider),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryNavy,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentGold,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions_rounded, size: 18), text: 'Por Aprobar'),
            Tab(icon: Icon(Icons.hotel_rounded, size: 18), text: 'Huéspedes en Casa'),
            Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'Historial'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (bookings) {
          final pending = bookings.where((b) => b.status.toLowerCase() == 'pending').toList();
          final inHouse = bookings.where((b) => b.status.toLowerCase() == 'checkedin' || b.status.toLowerCase() == 'confirmed').toList();
          final completed = bookings.where((b) => b.status.toLowerCase() == 'checkedout' || b.status.toLowerCase() == 'cancelled').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(pending, isPending: true, isDesktop: isDesktop),
              _buildBookingsList(inHouse, isInHouse: true, isDesktop: isDesktop),
              _buildBookingsList(completed, isHistory: true, isDesktop: isDesktop),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> list, {bool isPending = false, bool isInHouse = false, bool isHistory = false, bool isDesktop = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              isPending ? 'No hay reservaciones pendientes de aprobación' : (isInHouse ? 'No hay huéspedes con estadía activa hoy' : 'No hay historial registrado'),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.all(isDesktop ? 24 : 14),
        child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final b = list[index];
            return _buildBookingCard(b, isPending: isPending, isInHouse: isInHouse);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b, {bool isPending = false, bool isInHouse = false}) {
    final dateFormat = DateFormat('d MMM yyyy', 'es_ES');
    final checkInStr = dateFormat.format(b.checkInDate);
    final checkOutStr = dateFormat.format(b.checkOutDate);
    final totalVes = b.totalAmountUsd * 765.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code, Room number, and Status Chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.bookingCode.isNotEmpty ? b.bookingCode : 'RESERVA',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF061325)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Hab. ${b.roomNumber} • ${b.roomTitle}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              _buildStatusBadge(b.status),
            ],
          ),
          const SizedBox(height: 14),

          // Guest Details & Dates
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          b.guestName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          '$checkInStr — $checkOutStr (${b.totalNights} noches • ${b.guestsCount} personas)',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price block
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatUsd(b.totalAmountUsd),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
                  ),
                  Text(
                    '${CurrencyFormatter.formatVes(totalVes)} Bs.',
                    style: const TextStyle(color: AppTheme.caribbeanTeal, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          if (b.specialRequests != null && b.specialRequests!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgCanvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppTheme.accentBronze),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Petición Especial: ${b.specialRequests}',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textBody),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          if (isPending || isInHouse) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: const Text('Aprobar Reservación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _approveBooking(b.id),
                  ),
                ] else if (b.status.toLowerCase() == 'confirmed') ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.key_rounded, size: 16),
                    label: const Text('Registrar Check-In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _checkIn(b.id),
                  ),
                ] else if (b.status.toLowerCase() == 'checkedin') ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('Procesar Check-Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningOrange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _checkOut(b.id),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = AppTheme.successGreen;
        label = 'Confirmada';
        break;
      case 'checkedin':
        bg = AppTheme.primaryNavy;
        label = 'En Casa';
        break;
      case 'pending':
        bg = AppTheme.warningOrange;
        label = 'Por Aprobar';
        break;
      case 'checkedout':
        bg = Colors.grey.shade600;
        label = 'Completada';
        break;
      default:
        bg = Colors.grey.shade500;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bg.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(color: bg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
