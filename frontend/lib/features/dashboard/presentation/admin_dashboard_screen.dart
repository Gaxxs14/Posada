import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: statsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryNavy),
              SizedBox(height: 16),
              Text('Cargando métricas en tiempo real...', style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.errorRed.withAlpha(20), shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_off, size: 48, color: AppTheme.errorRed),
                ),
                const SizedBox(height: 16),
                const Text('Error al sincronizar datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(error.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(dashboardStatsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar Conexión'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Luxury Welcome Hero Banner
                    _buildWelcomeHero(context, user?.fullName ?? 'Administrador', stats),
                    const SizedBox(height: 24),

                    // 2. Metric KPI Cards (4 Cards Grid)
                    _buildKpiGrid(isDesktop, stats),
                    const SizedBox(height: 28),

                    // 3. Middle Section: Chart + Room Status Breakdown
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
    final today = DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(DateTime.now());
    final occRate = (stats['occupancyRatePercentage'] as num?)?.toDouble() ?? 0.0;
    final occRooms = stats['occupiedRooms'] as int? ?? 0;
    // La tasa BCV viene de HotelSettings; si no viene en el dashboard, usamos 765.0 por defecto
    final bcvRate = (stats['usdExchangeRateBcv'] as num?)?.toDouble() ?? 765.0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF1E3A5F), Color(0xFF0F3E6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2540).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: AppTheme.accentGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Suite Administrativa • $today',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Hola, $userName!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hoy la ocupación del hotel se encuentra al ${occRate.toStringAsFixed(1)}% con $occRooms habitaciones activas.',
                  style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Column(
              children: [
                const Text('Tasa BCV Oficial', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatVes(bcvRate),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(bool isDesktop, Map<String, dynamic> stats) {
    final occRate = (stats['occupancyRatePercentage'] as num?)?.toDouble() ?? 0.0;
    final totalRooms = stats['totalRooms'] as int? ?? 0;
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
              icon: Icons.hotel,
              iconBgColor: AppTheme.primaryBlue,
              accentColor: AppTheme.primaryBlue,
            ),
            _buildStatCard(
              width: width,
              title: 'Ingresos del Mes (USD)',
              value: CurrencyFormatter.formatUsd(revenueUsd),
              subtitle: '${CurrencyFormatter.formatVes(revenueVes)} Bs.',
              icon: Icons.attach_money,
              iconBgColor: AppTheme.successGreen,
              accentColor: AppTheme.successGreen,
            ),
            _buildStatCard(
              width: width,
              title: 'Reservas Pendientes',
              value: '$pendingCount',
              subtitle: 'Por aprobar en recepción',
              icon: Icons.hourglass_top,
              iconBgColor: AppTheme.warningOrange,
              accentColor: AppTheme.warningOrange,
            ),
            _buildStatCard(
              width: width,
              title: 'Habitaciones Libres',
              value: '$availableRooms',
              subtitle: 'Listas para check-in hoy',
              icon: Icons.check_circle_outline,
              iconBgColor: AppTheme.secondaryTeal,
              accentColor: AppTheme.secondaryTeal,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: iconBgColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconBgColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('En Vivo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard(Map<String, dynamic> stats) {
    final List monthsList = stats['revenueByMonth'] ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Historial de Ingresos Mensuales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Comparativa de los últimos meses en USD', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('USD Facturado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: monthsList.isEmpty
                ? const Center(child: Text('No hay suficientes datos de facturación'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: monthsList.map((e) => ((e['revenueUsd'] as num?)?.toDouble() ?? 0.0)).reduce((a, b) => a > b ? a : b) * 1.3,
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
                            reservedSize: 40,
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
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    monthsList[index]['month']?.toString() ?? '',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
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
                                colors: [AppTheme.primaryNavy, AppTheme.primaryBlue],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de Habitaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Disponibilidad y ciclo de limpieza hoy', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 20),
          _buildStatusRow('Disponibles para reserva', available, AppTheme.successGreen, Icons.check_circle_outline),
          const Divider(height: 24),
          _buildStatusRow('Ocupadas por huéspedes', occupied, AppTheme.errorRed, Icons.hotel),
          const Divider(height: 24),
          _buildStatusRow('En Limpieza (Housekeeping)', cleaning, AppTheme.warningOrange, Icons.cleaning_services_outlined),
          const Divider(height: 24),
          _buildStatusRow('En Mantenimiento', maintenance, Colors.grey.shade600, Icons.build_outlined),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }
}
