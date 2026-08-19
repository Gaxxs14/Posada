import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/presentation/auth_controller.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/dashboard/stats');
  if (response.data['success'] == true) {
    return response.data['data'] as Map<String, dynamic>;
  }
  throw Exception(response.data['message'] ?? 'Error al cargar estadísticas');
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final user = ref.watch(authStateProvider).user;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: statsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.accentGold),
              SizedBox(height: 16),
              Text('Cargando métricas en tiempo real...', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.luxuryCardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off, size: 40, color: AppTheme.errorRed),
                ),
                const SizedBox(height: 16),
                Text('Error al sincronizar datos', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(error.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(dashboardStatsProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          color: AppTheme.accentGold,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isDesktop ? 32 : 18),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1350),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Luxury Welcome Hero Banner
                    _buildWelcomeHero(context, user?.fullName ?? 'Administrador', stats),
                    const SizedBox(height: 24),

                    // 2. Bento-Grid KPI Cards
                    _buildKpiGrid(isDesktop, stats),
                    const SizedBox(height: 28),

                    // 3. Analytics Chart + Room Status Breakdown
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildRevenueChartCard(stats)),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _buildRoomStatusCard(stats)),
                        ],
                      )
                    else ...[
                      _buildRevenueChartCard(stats),
                      const SizedBox(height: 20),
                      _buildRoomStatusCard(stats),
                    ],

                    const SizedBox(height: 28),

                    // 4. Live Rooms Summary Strip
                    _buildLiveRoomsSummary(stats),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHero(BuildContext context, String userName, Map<String, dynamic> stats) {
    String today;
    try {
      today = DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(DateTime.now());
    } catch (_) {
      final now = DateTime.now();
      today = '${now.day}/${now.month}/${now.year}';
    }
    final occRate = (stats['occupancyRatePercentage'] as num?)?.toDouble() ?? 0.0;
    final occRooms = stats['occupiedRooms'] as int? ?? 0;
    final totalRooms = stats['totalRooms'] as int? ?? 5;
    final bcvRate = (stats['usdExchangeRateBcv'] as num?)?.toDouble() ?? 765.0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.navyHeroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF061325).withAlpha(60),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag with Gold star
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentGold.withAlpha(120)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Suite Ejecutiva • $today',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '¡Hola, $userName!',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoy la ocupación del resort se encuentra al ${occRate.toStringAsFixed(1)}% ($occRooms de $totalRooms suites activas).',
                  style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Mini Occupancy Progress Bar
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nivel de Ocupación', style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 11)),
                          Text('${occRate.toStringAsFixed(0)}%', style: const TextStyle(color: AppTheme.accentGoldLight, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: totalRooms > 0 ? occRooms / totalRooms : 0.0,
                          minHeight: 7,
                          backgroundColor: Colors.white.withAlpha(30),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGoldLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Gold BCV Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.accentGold.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: AppTheme.accentGold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'TASA BCV OFICIAL',
                      style: TextStyle(
                        color: AppTheme.accentGoldLight.withAlpha(220),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatVes(bcvRate),
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                ),
                Text('Bs. / USD', style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(bool isDesktop, Map<String, dynamic> stats) {
    final occRate = (stats['occupancyRatePercentage'] as num?)?.toDouble() ?? 0.0;
    final totalRooms = stats['totalRooms'] as int? ?? 5;
    final occupiedRooms = stats['occupiedRooms'] as int? ?? 0;
    final revenueUsd = (stats['monthlyRevenueUsd'] as num?)?.toDouble() ?? 0.0;
    final revenueVes = (stats['monthlyRevenueVes'] as num?)?.toDouble() ?? 0.0;
    final pendingCount = stats['pendingBookings'] as int? ?? 0;
    final availableRooms = stats['availableRooms'] as int? ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = isDesktop ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        final width = (constraints.maxWidth - ((crossCount - 1) * 16)) / crossCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              width: width,
              title: 'Tasa de Ocupación',
              value: '${occRate.toStringAsFixed(1)}%',
              subtitle: '$occupiedRooms de $totalRooms habitaciones',
              icon: Icons.hotel_rounded,
              iconBgColor: AppTheme.primaryBlue,
              accentColor: AppTheme.primaryBlue,
              badgeText: 'En Vivo',
            ),
            _buildStatCard(
              width: width,
              title: 'Ingresos de Agosto (USD)',
              value: CurrencyFormatter.formatUsd(revenueUsd),
              subtitle: '${CurrencyFormatter.formatVes(revenueVes)} Bs. BCV',
              icon: Icons.monetization_on_rounded,
              iconBgColor: AppTheme.successGreen,
              accentColor: AppTheme.successGreen,
              badgeText: '+18% vs mes ant.',
            ),
            _buildStatCard(
              width: width,
              title: 'Reservas por Aprobar',
              value: '$pendingCount',
              subtitle: 'Requiere atención en recepción',
              icon: Icons.pending_actions_rounded,
              iconBgColor: AppTheme.warningOrange,
              accentColor: AppTheme.warningOrange,
              badgeText: pendingCount > 0 ? 'Acción Requerida' : 'Al Día',
            ),
            _buildStatCard(
              width: width,
              title: 'Habitaciones Libres',
              value: '$availableRooms',
              subtitle: 'Listas para check-in hoy',
              icon: Icons.door_front_door_rounded,
              iconBgColor: AppTheme.caribbeanTeal,
              accentColor: AppTheme.caribbeanTeal,
              badgeText: 'Disponibles',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color accentColor,
    required String badgeText,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconBgColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard(Map<String, dynamic> stats) {
    final List monthsList = stats['revenueLast6Months'] ?? stats['revenueByMonth'] ?? [];

    double maxRevenue = 0.0;
    for (final m in monthsList) {
      final val = (m['revenueUsd'] as num?)?.toDouble() ?? 0.0;
      if (val > maxRevenue) maxRevenue = val;
    }
    final chartMaxY = maxRevenue > 0 ? maxRevenue * 1.3 : 100.0;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rendimiento Financiero Semestral', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Facturación en USD y volumen de reservas', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentGold.withAlpha(80)),
                ),
                child: const Text('Facturado USD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: monthsList.isEmpty
                ? const Center(child: Text('Cargando historial de facturación...'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: chartMaxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final month = monthsList[group.x.toInt()]['month']?.toString() ?? '';
                            return BarTooltipItem(
                              '$month\n\$${rod.toY.toStringAsFixed(2)} USD',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (val, meta) => Text(
                              '\$${val.toInt()}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final index = val.toInt();
                              if (index >= 0 && index < monthsList.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    monthsList[index]['month']?.toString() ?? '',
                                    style: const TextStyle(color: AppTheme.textDark, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                      ),
                      barGroups: monthsList.asMap().entries.map((entry) {
                        final rev = (entry.value['revenueUsd'] as num?)?.toDouble() ?? 0.0;
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: rev,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0A2540), Color(0xFFC5A059)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 24,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStatusCard(Map<String, dynamic> stats) {
    final available = stats['availableRooms'] as int? ?? 0;
    final occupied = stats['occupiedRooms'] as int? ?? 0;
    final cleaning = stats['cleaningRooms'] as int? ?? 0;
    final maintenance = stats['maintenanceRooms'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado del Inventario', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('Control de llaves y ciclo de camareras', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 20),
          _buildStatusRow('Disponibles para Huéspedes', available, AppTheme.successGreen, Icons.check_circle_outline),
          const Divider(height: 22),
          _buildStatusRow('Ocupadas (Huéspedes en Casa)', occupied, AppTheme.primaryBlue, Icons.hotel),
          const Divider(height: 22),
          _buildStatusRow('En Limpieza (Housekeeping)', cleaning, AppTheme.warningOrange, Icons.cleaning_services_outlined),
          const Divider(height: 22),
          _buildStatusRow('En Mantenimiento Preventivo', maintenance, Colors.grey.shade600, Icons.build_outlined),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildLiveRoomsSummary(Map<String, dynamic> stats) {
    final List rooms = stats['roomsSummary'] ?? [];
    if (rooms.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Matriz de Habitaciones en Vivo', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Estado en tiempo real de cada suite del resort', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${rooms.length} Suites Totales', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: rooms.map((r) {
              final number = r['roomNumber']?.toString() ?? '';
              final title = r['title']?.toString() ?? '';
              final status = r['status']?.toString() ?? 'Available';
              final guest = r['currentGuestName']?.toString();

              Color statusColor;
              String statusLabel;
              if (status == 'Occupied') {
                statusColor = AppTheme.primaryBlue;
                statusLabel = 'Ocupada';
              } else if (status == 'NeedsCleaning') {
                statusColor = AppTheme.warningOrange;
                statusLabel = 'Limpieza';
              } else if (status == 'UnderMaintenance') {
                statusColor = Colors.grey.shade600;
                statusLabel = 'Mantenimiento';
              } else {
                statusColor = AppTheme.successGreen;
                statusLabel = 'Disponible';
              }

              return Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCanvas,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: statusColor.withAlpha(80), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Hab. $number',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF061325)),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guest != null ? 'Huésped: $guest' : statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
