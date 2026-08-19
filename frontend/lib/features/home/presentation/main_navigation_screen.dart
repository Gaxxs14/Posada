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

    // Define navigation destinations based on role
    final List<NavigationDestinationItem> items = isStaff
        ? [
            NavigationDestinationItem(
              title: 'Dashboard',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              screen: const AdminDashboardScreen(),
            ),
            NavigationDestinationItem(
              title: 'Recepción',
              icon: Icons.room_service_outlined,
              selectedIcon: Icons.room_service_rounded,
              screen: const ReceptionScreen(),
            ),
            NavigationDestinationItem(
              title: 'Habitaciones',
              icon: Icons.hotel_outlined,
              selectedIcon: Icons.hotel_rounded,
              screen: isAdmin ? const RoomManagementScreen() : const RoomCatalogScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Personal',
                icon: Icons.badge_outlined,
                selectedIcon: Icons.badge_rounded,
                screen: const StaffManagementScreen(),
              ),
            NavigationDestinationItem(
              title: 'Limpieza',
              icon: Icons.cleaning_services_outlined,
              selectedIcon: Icons.cleaning_services_rounded,
              screen: const HousekeepingScreen(),
            ),
            NavigationDestinationItem(
              title: 'Tours & Experiencias',
              icon: Icons.sailing_outlined,
              selectedIcon: Icons.sailing_rounded,
              screen: const ExperiencesScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Auditoría & Reportes',
                icon: Icons.analytics_outlined,
                selectedIcon: Icons.analytics_rounded,
                screen: const ReportsScreen(),
              ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome_rounded,
              screen: const AiConciergeScreen(),
            ),
            if (isAdmin)
              NavigationDestinationItem(
                title: 'Configuración',
                icon: Icons.tune_outlined,
                selectedIcon: Icons.tune_rounded,
                screen: const HotelSettingsScreen(),
              ),
          ]
        : [
            NavigationDestinationItem(
              title: 'Habitaciones',
              icon: Icons.hotel_outlined,
              selectedIcon: Icons.hotel_rounded,
              screen: const RoomCatalogScreen(),
            ),
            NavigationDestinationItem(
              title: 'Tours & Paseos',
              icon: Icons.sailing_outlined,
              selectedIcon: Icons.sailing_rounded,
              screen: const ExperiencesScreen(),
            ),
            NavigationDestinationItem(
              title: 'Mis Reservas',
              icon: Icons.confirmation_number_outlined,
              selectedIcon: Icons.confirmation_number_rounded,
              screen: const MyBookingsScreen(),
            ),
            NavigationDestinationItem(
              title: 'Concierge IA',
              icon: Icons.auto_awesome_outlined,
              selectedIcon: Icons.auto_awesome_rounded,
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
                // Ultra-Luxury Sidebar
                Container(
                  width: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF051120), Color(0xFF091F38), Color(0xFF07172B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 20,
                        offset: Offset(4, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Resort Brand Crest & Title
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppTheme.goldGlowShadow,
                              ),
                              child: const Icon(Icons.hotel_class, color: Color(0xFF051120), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Posada Resort',
                                    style: GoogleFonts.playfairDisplay(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
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
                                        isStaff ? 'Suite Administrativa' : 'Portal Huésped VIP',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppTheme.accentGoldLight.withAlpha(200),
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

                      Divider(color: Colors.white.withAlpha(15), height: 1),

                      // Navigation Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            final isSelected = _selectedIndex == idx;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => setState(() => _selectedIndex = idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.accentGold.withAlpha(25)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      border: isSelected
                                          ? Border.all(color: AppTheme.accentGold.withAlpha(120), width: 1)
                                          : Border.all(color: Colors.transparent),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? item.selectedIcon : item.icon,
                                          color: isSelected ? AppTheme.accentGoldLight : Colors.white60,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: isSelected ? Colors.white : Colors.white70,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            width: 5,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              gradient: AppTheme.goldGradient,
                                              borderRadius: BorderRadius.circular(3),
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
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.accentGold.withAlpha(50)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.currency_exchange, color: AppTheme.accentGold, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TASA OFICIAL BCV',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentGoldLight.withAlpha(200),
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

                      Divider(color: Colors.white.withAlpha(15), height: 1),

                      // User Profile Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.goldGlowShadow,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF051120), fontSize: 15),
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
                                    user?.role == 'Admin' ? 'Administrador' : (user?.role == 'Receptionist' ? 'Recepción' : 'Huésped'),
                                    style: TextStyle(fontSize: 11, color: AppTheme.accentGoldLight.withAlpha(180)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 20),
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

      // Mobile Bottom Navigation Bar (Ultra-Luxury floating style)
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFF061325),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndex == idx;

                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = idx),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accentGold.withAlpha(30) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected ? Border.all(color: AppTheme.accentGold.withAlpha(80)) : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isSelected ? AppTheme.accentGoldLight : Colors.white60,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.title.split(' ')[0], // Single word for mobile
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white60,
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
  final IconData selectedIcon;
  final Widget screen;

  NavigationDestinationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
