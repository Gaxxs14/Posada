import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_badge.dart';
import '../../rooms/data/room_repository.dart';
import '../../rooms/models/room_model.dart';
import '../../rooms/presentation/room_controller.dart';

class HousekeepingScreen extends ConsumerWidget {
  const HousekeepingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limpieza y Mantenimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(roomsListProvider),
          ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (rooms) {
          final cleaningRooms = rooms.where((r) => r.status.toLowerCase() == 'needscleaning').toList();
          final maintenanceRooms = rooms.where((r) => r.status.toLowerCase() == 'undermaintenance').toList();
          final otherRooms = rooms.where((r) => r.status.toLowerCase() != 'needscleaning' && r.status.toLowerCase() != 'undermaintenance').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (cleaningRooms.isNotEmpty) ...[
                _buildSectionHeader('🧹 Requieren Limpieza Urgente (${cleaningRooms.length})', AppTheme.warningOrange),
                ...cleaningRooms.map((r) => _buildRoomTile(context, ref, r)),
                const SizedBox(height: 20),
              ],
              if (maintenanceRooms.isNotEmpty) ...[
                _buildSectionHeader('🛠️ En Mantenimiento (${maintenanceRooms.length})', AppTheme.errorRed),
                ...maintenanceRooms.map((r) => _buildRoomTile(context, ref, r)),
                const SizedBox(height: 20),
              ],
              _buildSectionHeader('✨ Otras Habitaciones (${otherRooms.length})', AppTheme.primaryBlue),
              ...otherRooms.map((r) => _buildRoomTile(context, ref, r)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, WidgetRef ref, RoomModel r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withAlpha(20),
          child: Text('#${r.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue)),
        ),
        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Piso ${r.floor} • Capacidad: ${r.capacity} pers.'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(status: r.status),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (newStatus) async {
                final scaffold = ScaffoldMessenger.of(context);
                try {
                  final repo = ref.read(roomRepositoryProvider);
                  await repo.updateRoomStatus(r.id, newStatus);
                  ref.invalidate(roomsListProvider);
                  scaffold.showSnackBar(
                    SnackBar(content: Text('Estado de Habitación #${r.roomNumber} actualizado a $newStatus.')),
                  );
                } catch (e) {
                  scaffold.showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
                  );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'Available', child: Text('✅ Marcar Disponible (Limpia)')),
                PopupMenuItem(value: 'NeedsCleaning', child: Text('🧹 Marcar Para Limpieza')),
                PopupMenuItem(value: 'UnderMaintenance', child: Text('🛠️ Marcar En Mantenimiento')),
                PopupMenuItem(value: 'Occupied', child: Text('🏨 Marcar Ocupada')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
