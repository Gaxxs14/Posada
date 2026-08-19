import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../bookings/presentation/my_bookings_screen.dart';
import '../../concierge/presentation/ai_concierge_screen.dart';
import '../../dashboard/presentation/admin_dashboard_screen.dart';
import '../../experiences/presentation/experiences_screen.dart';
import '../../housekeeping/presentation/housekeeping_screen.dart';
import '../../reception/presentation/reception_screen.dart';
import '../../rooms/presentation/room_catalog_screen.dart';
import '../../settings/presentation/hotel_settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isStaff = user?.isStaff ?? false;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Define navigation destinations based on role
    final List<NavigationDestinationItem> items = isStaff
        ? [
            NavigationDestinationItem(
              title: 'Dashboard',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              screen: const AdminDashboardScreen(),
            ),
            NavigationDestinationItem(
              title: 'Recepción',
              icon: Icons.room_service_outlined,
              selectedIcon: Icons.room_service,
              screen: const ReceptionScreen(),
            ),
            NavigationDestinationItem(
              title: 'Habitaciones',
              icon: Icons.hotel_outlined,
              selectedIcon: Icons.hotel,
              screen: const RoomCatalogScreen(),
            ),
            NavigationDestinationItem(
              title: 'Limpieza',
              icon: Icons.cleaning_services_outlined,
              selectedIcon: Icons.cleaning_services,
              screen: const HousekeepingScreen(),
            ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome,
              screen: const AiConciergeScreen(),
            ),
            NavigationDestinationItem(
              title: 'Configuración',
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              screen: const HotelSettingsScreen(),
            ),
          ]
        : [
            NavigationDestinationItem(
              title: 'Habitaciones',
              icon: Icons.hotel_outlined,
              selectedIcon: Icons.hotel,
              screen: const RoomCatalogScreen(),
            ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome,
              screen: const AiConciergeScreen(),
            ),
            NavigationDestinationItem(
              title: 'Tours',
              icon: Icons.sailing_outlined,
              selectedIcon: Icons.sailing,
              screen: const ExperiencesScreen(),
            ),
            NavigationDestinationItem(
              title: 'Mis Reservas',
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month,
              screen: const MyBookingsScreen(),
            ),
          ];

    if (_selectedIndex >= items.length) {
      _selectedIndex = 0;
    }

    final currentScreen = items[_selectedIndex].screen;

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                // Desktop Navigation Sidebar
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Column(
                    children: [
                      // Sidebar Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.hotel, color: AppTheme.primaryBlue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Posada',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
                                ),
                                Text(
                                  isStaff ? 'Panel Staff' : 'Portal Huésped',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Nav Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final isSelected = _selectedIndex == idx;
                            return ListTile(
                              leading: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              selectedTileColor: AppTheme.primaryBlue.withAlpha(20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onTap: () => setState(() => _selectedIndex = idx),
                            );
                          },
                        ),
                      ),

                      // User Info & Logout Button
                      const Divider(height: 1),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.secondaryTeal.withAlpha(30),
                          child: Text(
                            user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal),
                          ),
                        ),
                        title: Text(
                          user?.fullName ?? 'Usuario',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          user?.role ?? '',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.logout, color: AppTheme.errorRed, size: 20),
                          tooltip: 'Cerrar Sesión',
                          onPressed: () => ref.read(authStateProvider.notifier).logout(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(child: currentScreen),
              ],
            )
          : currentScreen,

      // Mobile Bottom Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              destinations: items.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon, color: AppTheme.primaryBlue),
                  label: item.title,
                );
              }).toList(),
            ),
    );
  }
}

class NavigationDestinationItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;

  NavigationDestinationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
