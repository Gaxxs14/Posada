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
import '../../reports/presentation/reports_screen.dart';
import '../../rooms/presentation/room_catalog_screen.dart';
import '../../rooms/presentation/room_management_screen.dart';
import '../../settings/presentation/hotel_settings_screen.dart';
import '../../staff/presentation/staff_management_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isStaff = user?.isStaff ?? false;
    final isAdmin = user?.role == 'Admin';
    final isDesktop = MediaQuery.of(context).size.width > 900;

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
              screen: isAdmin ? const RoomManagementScreen() : const RoomCatalogScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Personal',
                icon: Icons.people_outline,
                selectedIcon: Icons.people,
                screen: const StaffManagementScreen(),
              ),
            NavigationDestinationItem(
              title: 'Limpieza',
              icon: Icons.cleaning_services_outlined,
              selectedIcon: Icons.cleaning_services,
              screen: const HousekeepingScreen(),
            ),
            NavigationDestinationItem(
              title: 'Tours',
              icon: Icons.sailing_outlined,
              selectedIcon: Icons.sailing,
              screen: const ExperiencesScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Reportes',
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                screen: const ReportsScreen(),
              ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome,
              screen: const AiConciergeScreen(),
            ),
            if (isAdmin)
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
                // Luxury Dark Navy Desktop Navigation Sidebar
                Container(
                  width: 270,
                  decoration: const BoxDecoration(
                    color: Color(0xFF07172B),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Sidebar Header with Gold accents
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFC5A059), Color(0xFFDFBA73)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.hotel_class, color: Color(0xFF07172B), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Posada Resort',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.successGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isStaff ? 'Panel Staff' : 'Portal Huésped',
                                      style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.white.withAlpha(20), height: 1),

                      // Nav Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final isSelected = _selectedIndex == idx;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                leading: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected ? const Color(0xFFDFBA73) : Colors.white60,
                                  size: 22,
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                selected: isSelected,
                                selectedTileColor: Colors.white.withAlpha(18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected
                                      ? BorderSide(color: const Color(0xFFC5A059).withAlpha(100), width: 1)
                                      : BorderSide.none,
                                ),
                                onTap: () => setState(() => _selectedIndex = idx),
                              ),
                            );
                          },
                        ),
                      ),

                      // User Info & Logout Button
                      Divider(color: Colors.white.withAlpha(20), height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFC5A059),
                              radius: 20,
                              child: Text(
                                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF07172B)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Usuario',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    user?.role ?? '',
                                    style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(150)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppTheme.errorRed, size: 20),
                              tooltip: 'Cerrar Sesión',
                              onPressed: () => ref.read(authStateProvider.notifier).logout(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
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
                  selectedIcon: Icon(item.selectedIcon, color: AppTheme.primaryNavy),
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
