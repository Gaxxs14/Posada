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
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
          const SnackBar(content: Text('Check-in completado. Huésped registrado en habitación.'), backgroundColor: AppTheme.successGreen),
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
          const SnackBar(content: Text('Check-out procesado. Habitación enviada a limpieza.'), backgroundColor: AppTheme.primaryNavy),
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
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: Text(
          'Recepción & Control de Huéspedes',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(allBookingsProvider),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (bookings) {
          // Filter by search query
          final filtered = bookings.where((b) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return b.guestName.toLowerCase().contains(q) ||
                b.bookingCode.toLowerCase().contains(q) ||
                b.roomNumber.toLowerCase().contains(q) ||
                b.roomTitle.toLowerCase().contains(q);
          }).toList();

          final pending = filtered.where((b) => b.status.toLowerCase() == 'pending').toList();
          final inHouse = filtered.where((b) => b.status.toLowerCase() == 'checkedin' || b.status.toLowerCase() == 'confirmed').toList();
          final completed = filtered.where((b) => b.status.toLowerCase() == 'checkedout' || b.status.toLowerCase() == 'cancelled').toList();

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1250),
              padding: EdgeInsets.all(isDesktop ? 24 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Search Bar & Quick Filters
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.cleanCardShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            decoration: const InputDecoration(
                              hintText: 'Buscar por nombre de huésped, código de reserva (POS-...) o habitación...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Tab Selector with Dynamic Badges
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryNavy,
                      unselectedLabelColor: AppTheme.textMuted,
                      indicatorColor: AppTheme.primaryAccent,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.pending_actions, size: 16),
                              const SizedBox(width: 6),
                              Text('Por Aprobar (${pending.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.hotel, size: 16),
                              const SizedBox(width: 6),
                              Text('En Casa (${inHouse.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.history, size: 16),
                              const SizedBox(width: 6),
                              Text('Historial (${completed.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Tab Contents
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(pending, isPending: true),
                        _buildList(inHouse, isInHouse: true),
                        _buildList(completed, isHistory: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<BookingModel> list, {bool isPending = false, bool isInHouse = false, bool isHistory = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              isPending
                  ? 'No hay solicitudes de reservación pendientes de aprobación.'
                  : (isInHouse ? 'No hay huéspedes con estadía activa en este momento.' : 'No hay historial registrado.'),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = list[index];
        return _buildCard(b, isPending: isPending, isInHouse: isInHouse);
      },
    );
  }

  Widget _buildCard(BookingModel b, {bool isPending = false, bool isInHouse = false}) {
    final dateFormat = DateFormat('d MMM yyyy', 'es_ES');
    final checkInStr = dateFormat.format(b.checkInDate);
    final checkOutStr = dateFormat.format(b.checkOutDate);
    final totalVes = b.totalAmountUsd * 765.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code, Room number, and Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.bookingCode.isNotEmpty ? b.bookingCode : 'RESERVA',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Hab. ${b.roomNumber} • ${b.roomTitle}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark),
              ),
              const Spacer(),
              _buildStatusBadge(b.status),
            ],
          ),
          const SizedBox(height: 14),

          // Guest & Stay Information
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guest avatar & name
              CircleAvatar(
                backgroundColor: AppTheme.primaryAccent.withAlpha(25),
                radius: 18,
                child: Text(
                  b.guestName.isNotEmpty ? b.guestName[0].toUpperCase() : 'G',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAccent, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.guestName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 13, color: AppTheme.textMuted),
                        const SizedBox(width: 5),
                        Text(
                          '$checkInStr — $checkOutStr',
                          style: const TextStyle(color: AppTheme.textBody, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${b.totalNights} noches • ${b.guestsCount} pers.',
                            style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price block (USD + Bs.)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatUsd(b.totalAmountUsd),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
                  ),
                  Text(
                    '${CurrencyFormatter.formatVes(totalVes)} Bs.',
                    style: const TextStyle(color: AppTheme.accentEmerald, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),

          if (b.specialRequests != null && b.specialRequests!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 14, color: AppTheme.primaryAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Petición: ${b.specialRequests}',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textBody),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons Bar
          if (isPending || isInHouse) ...[
            const Divider(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aprobar Reservación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentEmerald,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _approveBooking(b.id),
                  ),
                ] else if (b.status.toLowerCase() == 'confirmed') ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.key, size: 16),
                    label: const Text('Registrar Check-In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _checkIn(b.id),
                  ),
                ] else if (b.status.toLowerCase() == 'checkedin') ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app, size: 16),
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
        bg = AppTheme.primaryAccent;
        label = 'Confirmada';
        break;
      case 'checkedin':
        bg = AppTheme.accentEmerald;
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(color: bg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
