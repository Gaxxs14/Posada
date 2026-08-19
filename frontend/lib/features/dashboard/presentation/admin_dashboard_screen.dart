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
              CircularProgressIndicator(color: AppTheme.primaryAccent),
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: AppTheme.cleanCardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off, size: 36, color: AppTheme.errorRed),
                ),
                const SizedBox(height: 16),
                Text('Error al sincronizar datos', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
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
          color: AppTheme.primaryAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isDesktop ? 28 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1350),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Clean Luminous Welcome Hero
                    _buildWelcomeHero(context, user?.fullName ?? 'Administrador', stats),
                    const SizedBox(height: 22),

                    // 2. Bento-Grid KPI Cards
                    _buildKpiGrid(isDesktop, stats),
                    const SizedBox(height: 24),

                    // 3. Analytics Chart + Room Status Breakdown
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildRevenueChartCard(stats)),
                          const SizedBox(width: 22),
                          Expanded(flex: 2, child: _buildRoomStatusCard(stats)),
                        ],
                      )
                    else ...[
                      _buildRevenueChartCard(stats),
                      const SizedBox(height: 18),
                      _buildRoomStatusCard(stats),
                    ],

                    const SizedBox(height: 24),

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
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.heroShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Panel de Control • $today',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Bienvenido, $userName!',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ocupación actual al ${occRate.toStringAsFixed(1)}% ($occRooms de $totalRooms habitaciones ocupadas).',
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13.5),
                ),
                const SizedBox(height: 14),

                Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalRooms > 0 ? occRooms / totalRooms : 0.0,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF1E293B),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentEmerald),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BCV Rate Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'TASA BCV OFICIAL',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatVes(bcvRate),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Text('Bs. / USD', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
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
              subtitle: '$occupiedRooms de $totalRooms suites',
              icon: Icons.hotel,
              iconBgColor: AppTheme.primaryAccent,
              accentColor: AppTheme.primaryAccent,
            ),
            _buildStatCard(
              width: width,
              title: 'Ingresos del Mes (USD)',
              value: CurrencyFormatter.formatUsd(revenueUsd),
              subtitle: '${CurrencyFormatter.formatVes(revenueVes)} Bs. BCV',
              icon: Icons.attach_money,
              iconBgColor: AppTheme.accentEmerald,
              accentColor: AppTheme.accentEmerald,
            ),
            _buildStatCard(
              width: width,
              title: 'Reservas por Aprobar',
              value: '$pendingCount',
              subtitle: 'Requiere atención',
              icon: Icons.pending_actions,
              iconBgColor: AppTheme.warningOrange,
              accentColor: AppTheme.warningOrange,
            ),
            _buildStatCard(
              width: width,
              title: 'Habitaciones Libres',
              value: '$availableRooms',
              subtitle: 'Disponibles hoy',
              icon: Icons.check_circle,
              iconBgColor: AppTheme.accentAzure,
              accentColor: AppTheme.accentAzure,
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
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconBgColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('En Vivo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
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
                  Text('Historial de Facturación (USD)', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Rendimiento financiero de los últimos 6 meses', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('USD Facturado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 220,
            child: monthsList.isEmpty
                ? const Center(child: Text('Cargando historial...'))
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
                            reservedSize: 42,
                            getTitlesWidget: (val, meta) => Text(
                              '\$${val.toInt()}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
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
                        getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.borderLight, strokeWidth: 1),
                      ),
                      barGroups: monthsList.asMap().entries.map((entry) {
                        final rev = (entry.value['revenueUsd'] as num?)?.toDouble() ?? 0.0;
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: rev,
                              color: AppTheme.primaryAccent,
                              width: 22,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado de Habitaciones', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Control de inventario y camareras', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 18),
          _buildStatusRow('Disponibles para reserva', available, AppTheme.accentEmerald, Icons.check_circle),
          const Divider(height: 20),
          _buildStatusRow('Ocupadas (Huéspedes en casa)', occupied, AppTheme.primaryNavy, Icons.hotel),
          const Divider(height: 20),
          _buildStatusRow('En Limpieza (Housekeeping)', cleaning, AppTheme.warningOrange, Icons.cleaning_services),
          const Divider(height: 20),
          _buildStatusRow('En Mantenimiento', maintenance, Colors.grey.shade600, Icons.build),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(18), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13.5)),
        ),
      ],
    );
  }

  Widget _buildLiveRoomsSummary(Map<String, dynamic> stats) {
    final List rooms = stats['roomsSummary'] ?? [];
    if (rooms.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
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
                  Text('Matriz de Suites en Tiempo Real', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Estado de cada habitación de la posada', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${rooms.length} Suites Totales', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: rooms.map((r) {
              final number = r['roomNumber']?.toString() ?? '';
              final title = r['title']?.toString() ?? '';
              final status = r['status']?.toString() ?? 'Available';
              final guest = r['currentGuestName']?.toString();

              Color statusColor;
              String statusLabel;
              if (status == 'Occupied') {
                statusColor = AppTheme.primaryNavy;
                statusLabel = 'Ocupada';
              } else if (status == 'NeedsCleaning') {
                statusColor = AppTheme.warningOrange;
                statusLabel = 'Limpieza';
              } else if (status == 'UnderMaintenance') {
                statusColor = Colors.grey.shade600;
                statusLabel = 'Mantenimiento';
              } else {
                statusColor = AppTheme.accentEmerald;
                statusLabel = 'Disponible';
              }

              return Container(
                width: 210,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgCanvas,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withAlpha(60), width: 1.2),
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
                            color: AppTheme.primaryNavy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Hab. $number',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    const SizedBox(height: 3),
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
