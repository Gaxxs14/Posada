import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
          const SnackBar(content: Text('Check-in realizado. Habitación marcada como Ocupada.'), backgroundColor: AppTheme.successGreen),
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
          const SnackBar(content: Text('Check-out realizado. Habitación enviada a Limpieza.'), backgroundColor: AppTheme.secondaryTeal),
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

  void _showExtraChargeDialog(BookingModel booking) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Agregar Consumo / Cargo (#${booking.roomNumber})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción', hintText: 'Ej: Bebidas, Desayuno, Lavandería'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto USD (\$)', prefixText: '\$ '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (descController.text.isEmpty || amount <= 0) return;
              Navigator.pop(context);
              try {
                final repo = ref.read(bookingRepositoryProvider);
                await repo.addExtraCharge(booking.id, {
                  'description': descController.text.trim(),
                  'amountUsd': amount,
                  'quantity': 1,
                });
                ref.invalidate(allBookingsProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cargo agregado a la cuenta.'), backgroundColor: AppTheme.successGreen),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.errorRed),
                  );
                }
              }
            },
            child: const Text('Agregar Cargo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBookingsAsync = ref.watch(allBookingsProvider);
    final roomsAsync = ref.watch(roomsListProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recepción & Front Desk'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.bookmark_border), text: 'Gestión de Reservaciones'),
            Tab(icon: Icon(Icons.grid_view), text: 'Estado de Habitaciones'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(allBookingsProvider);
              ref.invalidate(roomsListProvider);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Bookings Management
          allBookingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
            data: (bookings) {
              if (bookings.isEmpty) {
                return const Center(child: Text('No hay reservaciones registradas'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${b.bookingCode} - ${b.guestName}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              StatusBadge(status: b.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Habitación: #${b.roomNumber} (${b.roomTitle})', style: const TextStyle(color: AppTheme.textMuted)),
                          Text(
                            'Fechas: ${dateFormat.format(b.checkInDate)} al ${dateFormat.format(b.checkOutDate)} (${b.totalNights} noches)',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Total: ${CurrencyFormatter.formatDual(b.totalAmountUsd, b.exchangeRateUsed)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                          const Divider(height: 16),

                          // Action Buttons
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (b.isPending)
                                ElevatedButton.icon(
                                  onPressed: () => _approveBooking(b.id),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Aprobar Reserva'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                                ),
                              if (b.isConfirmed)
                                ElevatedButton.icon(
                                  onPressed: () => _checkIn(b.id),
                                  icon: const Icon(Icons.login, size: 16),
                                  label: const Text('Check-In (Huésped Llegó)'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                                ),
                              if (b.isCheckedIn) ...[
                                ElevatedButton.icon(
                                  onPressed: () => _checkOut(b.id),
                                  icon: const Icon(Icons.logout, size: 16),
                                  label: const Text('Check-Out (Salida)'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _showExtraChargeDialog(b),
                                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                                  label: const Text('Cargar Consumo'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Tab 2: Live Room Status Grid
          roomsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(err.toString())),
            data: (rooms) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final r = rooms[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${r.roomNumber}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              ),
                              StatusBadge(status: r.status),
                            ],
                          ),
                          Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Capacidad: ${r.capacity} pers. | Piso ${r.floor}', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                          Text(CurrencyFormatter.formatUsd(r.pricePerNightUsd), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
