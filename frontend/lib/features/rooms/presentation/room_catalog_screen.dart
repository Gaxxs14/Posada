import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../bookings/presentation/create_booking_dialog.dart';
import '../models/room_model.dart';
import 'room_controller.dart';

class RoomCatalogScreen extends ConsumerWidget {
  const RoomCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsListProvider);
    final selectedType = ref.watch(roomFilterTypeProvider);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitaciones Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(roomsListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Carousel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip(ref, 'Todas', null, selectedType == null),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Matrimonial', 'Double', selectedType == 'Double'),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Suite Frente al Mar', 'Suite', selectedType == 'Suite'),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Familiar', 'Family', selectedType == 'Family'),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Triple', 'Triple', selectedType == 'Triple'),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Individual', 'Single', selectedType == 'Single'),
              ],
            ),
          ),

          // Catalog Content
          Expanded(
            child: roomsAsync.when(
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
                      onPressed: () => ref.refresh(roomsListProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return const Center(
                    child: Text('No hay habitaciones que coincidan con el filtro.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                    childAspectRatio: isDesktop ? 0.85 : 0.95,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _buildRoomCard(context, room);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String? typeValue, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryBlue.withAlpha(40),
      checkmarkColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        ref.read(roomFilterTypeProvider.notifier).state = typeValue;
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomModel room) {
    final imageUrl = room.imageUrls.isNotEmpty
        ? room.imageUrls.first
        : 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Header with status badge
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.hotel, size: 48, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Habitación #${room.roomNumber}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: StatusBadge(status: room.status),
              ),
            ],
          ),

          // Details Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // Amenities Chips (up to 3)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: room.amenities.take(3).map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(a, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      );
                    }).toList(),
                  ),

                  const Spacer(),
                  const Divider(height: 16),

                  // Price and Booking Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Por noche', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          Text(
                            CurrencyFormatter.formatUsd(room.pricePerNightUsd),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: room.isAvailable
                            ? () => CreateBookingDialog.show(context, room)
                            : null,
                        icon: const Icon(Icons.calendar_month, size: 16),
                        label: Text(room.isAvailable ? 'Reservar' : 'No Disp.'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          backgroundColor: room.isAvailable ? AppTheme.primaryBlue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
