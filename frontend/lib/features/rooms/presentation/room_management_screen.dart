import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/room_model.dart';
import 'room_controller.dart';

class RoomManagementScreen extends ConsumerWidget {
  const RoomManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Habitaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(roomsListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva Habitación'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showRoomFormDialog(context, ref),
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('No hay habitaciones registradas. Crea la primera con el botón de abajo.'));
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: rooms.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              room.roomNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 10),
                                    _buildStatusBadge(room.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Piso ${room.floor} • Capacidad: ${room.capacity} personas • ${room.type}',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: room.amenities.take(4).map((a) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(a, style: const TextStyle(fontSize: 10)),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.formatUsd(room.pricePerNightUsd),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
                              ),
                              const Text('por noche', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryBlue),
                                    tooltip: 'Editar',
                                    onPressed: () => _showRoomFormDialog(context, ref, room: room),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.errorRed),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _deleteRoom(context, ref, room.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'Available':
        bg = AppTheme.successGreen.withAlpha(30);
        fg = AppTheme.successGreen;
        label = 'Disponible';
        break;
      case 'Occupied':
        bg = AppTheme.errorRed.withAlpha(30);
        fg = AppTheme.errorRed;
        label = 'Ocupada';
        break;
      case 'Cleaning':
        bg = AppTheme.accentGold.withAlpha(30);
        fg = Colors.orange.shade800;
        label = 'Limpieza';
        break;
      case 'Maintenance':
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = 'Mantenimiento';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _deleteRoom(BuildContext context, WidgetRef ref, String roomId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar habitación?'),
        content: const Text('Esta acción eliminará la habitación del catálogo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final apiClient = ref.read(apiClientProvider);
              await apiClient.dio.delete('/api/rooms/$roomId');
              ref.invalidate(roomsListProvider);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showRoomFormDialog(BuildContext context, WidgetRef ref, {RoomModel? room}) {
    final isEditing = room != null;
    final numberCtrl = TextEditingController(text: room?.roomNumber ?? '');
    final titleCtrl = TextEditingController(text: room?.title ?? '');
    final descCtrl = TextEditingController(text: room?.description ?? '');
    final priceCtrl = TextEditingController(text: room?.pricePerNightUsd.toString() ?? '50');
    final capacityCtrl = TextEditingController(text: room?.capacity.toString() ?? '2');
    final floorCtrl = TextEditingController(text: room?.floor.toString() ?? '1');
    final imageCtrl = TextEditingController(
      text: room?.imageUrls.isNotEmpty == true
          ? room!.imageUrls.first
          : 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
    );

    String selectedType = room?.type ?? 'Double';
    final List<String> availableAmenities = [
      'WiFi Alta Velocidad',
      'Aire Acondicionado',
      'Smart TV',
      'Baño Privado',
      'Agua Caliente',
      'Vista al Mar',
      'Jacuzzi Privado',
      'Cocina Equipada',
      'Minibar Incluido',
      'Desayuno Incluido',
      'Balcón',
      'Estacionamiento Privado',
    ];

    final Set<String> selectedAmenities = Set.from(room?.amenities ?? ['WiFi Alta Velocidad', 'Aire Acondicionado', 'Baño Privado']);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Habitación' : 'Registrar Nueva Habitación'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: numberCtrl,
                          decoration: const InputDecoration(labelText: 'Número / Código (ej. 101, 204)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(labelText: 'Tipo de Habitación'),
                          items: const [
                            DropdownMenuItem(value: 'Single', child: Text('Individual')),
                            DropdownMenuItem(value: 'Double', child: Text('Matrimonial / Doble')),
                            DropdownMenuItem(value: 'Triple', child: Text('Triple')),
                            DropdownMenuItem(value: 'Suite', child: Text('Suite Deluxe')),
                            DropdownMenuItem(value: 'Family', child: Text('Familiar')),
                          ],
                          onChanged: (val) => setDialogState(() => selectedType = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título Descriptivo (ej. Suite Vista al Mar)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descripción Detallada'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio USD / Noche', prefixText: '\$ '),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: capacityCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Capacidad Máx (Personas)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: floorCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Piso'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: 'URL de Imagen Principal (Unsplash / Cloud)'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Amenidades y Servicios Incluidos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: availableAmenities.map((amenity) {
                      final isSelected = selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppTheme.textDark)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryBlue,
                        checkmarkColor: Colors.white,
                        onSelected: (checked) {
                          setDialogState(() {
                            if (checked) {
                              selectedAmenities.add(amenity);
                            } else {
                              selectedAmenities.remove(amenity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final num = numberCtrl.text.trim();
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text) ?? 50.0;
                final capacity = int.tryParse(capacityCtrl.text) ?? 2;
                final floor = int.tryParse(floorCtrl.text) ?? 1;
                final img = imageCtrl.text.trim();

                if (num.isEmpty || title.isEmpty) return;

                final data = {
                  'roomNumber': num,
                  'title': title,
                  'description': desc,
                  'type': selectedType,
                  'pricePerNightUsd': price,
                  'capacity': capacity,
                  'floor': floor,
                  'amenities': selectedAmenities.toList(),
                  'imageUrls': [img],
                };

                final apiClient = ref.read(apiClientProvider);
                if (isEditing) {
                  await apiClient.dio.put('/api/rooms/${room.id}', data: data);
                } else {
                  await apiClient.dio.post('/api/rooms', data: data);
                }

                if (context.mounted) Navigator.pop(dialogCtx);
                ref.invalidate(roomsListProvider);
              },
              child: Text(isEditing ? 'Guardar Cambios' : 'Registrar Habitación'),
            ),
          ],
        ),
      ),
    );
  }
}
