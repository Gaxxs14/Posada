import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../data/room_repository.dart';
import '../models/room_model.dart';
import 'room_controller.dart';

class RoomManagementScreen extends ConsumerWidget {
  const RoomManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsListProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: Text('Inventario de Habitaciones', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar Habitaciones',
            onPressed: () => ref.invalidate(roomsListProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Habitación', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        onPressed: () => _showRoomFormDialog(context, ref),
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('No hay habitaciones registradas.'));
          }

          final crossCount = isDesktop ? (size.width > 1400 ? 3 : 2) : 1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 28 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header summary banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.navyHeroGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.luxuryCardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.hotel, color: Color(0xFF061325), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Catálogo de Suites & Cabañas', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Administra tarifas en USD, estados de ocupación y amenidades', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                            ),
                            child: Text(
                              '${rooms.length} Suites Totales',
                              style: const TextStyle(color: AppTheme.accentGoldLight, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid of luxury room cards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 420,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return _buildLuxuryRoomCard(context, ref, room);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLuxuryRoomCard(BuildContext context, WidgetRef ref, RoomModel room) {
    final imageUrl = room.imageUrls.isNotEmpty
        ? room.imageUrls[0]
        : 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800';
    final priceVes = room.pricePerNightUsd * 765.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Room Image with Overlay Badges
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: AppTheme.primaryNavy,
                  child: const Center(child: Icon(Icons.hotel, size: 48, color: Colors.white24)),
                ),
              ),
              // Top Badges (Room Number + Status)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppTheme.goldGlowShadow,
                  ),
                  child: Text(
                    'Hab. ${room.roomNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF061325)),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(room.status),
              ),
              // Bottom Price Badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.formatUsd(room.pricePerNightUsd),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${CurrencyFormatter.formatVes(priceVes)} Bs./noche',
                        style: TextStyle(color: AppTheme.accentGoldLight.withAlpha(220), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Room Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Piso ${room.floor} • Capacidad: ${room.capacity} personas • ${room.type}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),

                // Amenities Wrap
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: room.amenities.take(3).map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCanvas,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 10.5, color: AppTheme.textBody, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Quick Status Changer Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cleaning_services, size: 14),
                        label: const Text('Limpieza', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.warningOrange,
                          side: const BorderSide(color: AppTheme.warningOrange),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _updateRoomStatus(context, ref, room.id, 'NeedsCleaning'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text('Disponible', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.successGreen,
                          side: const BorderSide(color: AppTheme.successGreen),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _updateRoomStatus(context, ref, room.id, 'Available'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'available':
        bg = AppTheme.successGreen;
        fg = Colors.white;
        label = 'Disponible';
        break;
      case 'occupied':
        bg = AppTheme.primaryNavy;
        fg = Colors.white;
        label = 'Ocupada';
        break;
      case 'needscleaning':
        bg = AppTheme.warningOrange;
        fg = Colors.white;
        label = 'En Limpieza';
        break;
      case 'undermaintenance':
        bg = AppTheme.errorRed;
        fg = Colors.white;
        label = 'Mantenimiento';
        break;
      default:
        bg = Colors.grey.shade600;
        fg = Colors.white;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  void _updateRoomStatus(BuildContext context, WidgetRef ref, String roomId, String status) async {
    try {
      final repo = ref.read(roomRepositoryProvider);
      await repo.updateRoomStatus(roomId, status);
      ref.invalidate(roomsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a $status'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _showRoomFormDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final numController = TextEditingController();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    int capacity = 2;
    int floor = 1;
    String type = 'Double';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('Nueva Habitación', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numController,
                    decoration: const InputDecoration(labelText: 'Número de Habitación (ej. 301)'),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título Descriptivo'),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tarifa USD por noche (\$)', prefixText: '\$ '),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Tipo de Habitación'),
                    items: const [
                      DropdownMenuItem(value: 'Single', child: Text('Individual (Single)')),
                      DropdownMenuItem(value: 'Double', child: Text('Matrimonial / Doble (Double)')),
                      DropdownMenuItem(value: 'Triple', child: Text('Triple (Triple)')),
                      DropdownMenuItem(value: 'Suite', child: Text('Suite de Lujo (Suite)')),
                      DropdownMenuItem(value: 'Family', child: Text('Cabaña Familiar (Family)')),
                    ],
                    onChanged: (val) => setState(() => type = val!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final repo = ref.read(roomRepositoryProvider);
                    await repo.createRoom({
                      'roomNumber': numController.text.trim(),
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'pricePerNightUsd': double.parse(priceController.text.trim()),
                      'type': type,
                      'capacity': capacity,
                      'floor': floor,
                      'amenities': ['WiFi Alta Velocidad', 'Aire Acondicionado', 'Smart TV', 'Baño Privado'],
                      'imageUrls': ['https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800'],
                    });
                    ref.invalidate(roomsListProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Habitación creada exitosamente'), backgroundColor: AppTheme.successGreen),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
                      );
                    }
                  }
                }
              },
              child: const Text('Crear Habitación'),
            ),
          ],
        ),
      ),
    );
  }
}
