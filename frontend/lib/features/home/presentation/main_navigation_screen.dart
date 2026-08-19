import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
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
    final isDesktop = MediaQuery.of(context).size.width > 960;

    // Define navigation destinations with standard solid Material Icons
    final List<NavigationDestinationItem> items = isStaff
        ? [
            NavigationDestinationItem(
              title: 'Dashboard',
              icon: Icons.dashboard,
              screen: const AdminDashboardScreen(),
            ),
            NavigationDestinationItem(
              title: 'Recepción',
              icon: Icons.room_service,
              screen: const ReceptionScreen(),
            ),
            NavigationDestinationItem(
              title: 'Habitaciones',
              icon: Icons.hotel,
              screen: isAdmin ? const RoomManagementScreen() : const RoomCatalogScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Personal',
                icon: Icons.people,
                screen: const StaffManagementScreen(),
              ),
            NavigationDestinationItem(
              title: 'Limpieza',
              icon: Icons.cleaning_services,
              screen: const HousekeepingScreen(),
            ),
            NavigationDestinationItem(
              title: 'Tours & Paseos',
              icon: Icons.sailing,
              screen: const ExperiencesScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Auditoría',
                icon: Icons.bar_chart,
                screen: const ReportsScreen(),
              ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.chat,
              screen: const AiConciergeScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Configuración',
                icon: Icons.settings,
                screen: const HotelSettingsScreen(),
              ),
          ]
        : [
            NavigationDestinationItem(
              title: 'Habitaciones',
              icon: Icons.hotel,
              screen: const RoomCatalogScreen(),
            ),
            NavigationDestinationItem(
              title: 'Tours',
              icon: Icons.sailing,
              screen: const ExperiencesScreen(),
            ),
            NavigationDestinationItem(
              title: 'Mis Reservas',
              icon: Icons.confirmation_number,
              screen: const MyBookingsScreen(),
            ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.chat,
              screen: const AiConciergeScreen(),
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
                // Clean Modern Desktop Sidebar
                Container(
                  width: 270,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 16,
                        offset: Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Logo & Brand
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.hotel, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Posada Resort',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
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
                                        isStaff ? 'Consola de Gestión' : 'Portal Huésped',
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFF1E293B), height: 1),

                      // Navigation Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final isSelected = _selectedIndex == idx;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => setState(() => _selectedIndex = idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primaryAccent : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.icon,
                                          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                          size: 19,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // BCV Official Rate Widget in Sidebar Footer
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.currency_exchange, color: AppTheme.accentEmerald, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TASA OFICIAL BCV',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.formatVes(765.00)} Bs. / USD',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFF1E293B), height: 1),

                      // User Profile Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryAccent,
                              radius: 17,
                              child: Text(
                                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Usuario',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    user?.role == 'Admin' ? 'Administrador' : (user?.role == 'Receptionist' ? 'Recepción' : 'Huésped'),
                                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: AppTheme.errorRed, size: 18),
                              tooltip: 'Cerrar Sesión',
                              onPressed: () => ref.read(authStateProvider.notifier).logout(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: ColoredBox(
                    color: AppTheme.bgCanvas,
                    child: currentScreen,
                  ),
                ),
              ],
            )
          : currentScreen,

      // Mobile Bottom Navigation Bar (Clean luminous style)
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndex == idx;

                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = idx),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                size: 20,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.title.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}

class NavigationDestinationItem {
  final String title;
  final IconData icon;
  final Widget screen;

  NavigationDestinationItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}
