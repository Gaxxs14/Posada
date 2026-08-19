import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../bookings/presentation/booking_controller.dart';
import '../../rooms/presentation/room_controller.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get(ApiEndpoints.dashboardStats);
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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(roomsListProvider);
              ref.invalidate(allBookingsProvider);
            },
          ),
        ],
      ),
      body: statsAsync.when(
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
                onPressed: () => ref.refresh(dashboardStatsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (stats) {
          final totalRooms = stats['totalRooms'] ?? 0;
          final availableRooms = stats['availableRooms'] ?? 0;
          final occupiedRooms = stats['occupiedRooms'] ?? 0;
          final cleaningRooms = stats['cleaningRooms'] ?? 0;
          final occupancyRate = (stats['occupancyRatePercentage'] as num?)?.toDouble() ?? 0.0;
          final pendingBookings = stats['pendingBookings'] ?? 0;
          final monthlyRevenueUsd = (stats['monthlyRevenueUsd'] as num?)?.toDouble() ?? 0.0;
          final monthlyRevenueVes = (stats['monthlyRevenueVes'] as num?)?.toDouble() ?? 0.0;
          final List revenueHistory = stats['revenueLast6Months'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Stat Cards Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = isDesktop ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              title: 'Tasa de Ocupación',
                              value: '$occupancyRate%',
                              subtitle: '$occupiedRooms de $totalRooms habitaciones',
                              icon: Icons.pie_chart_outline,
                              color: AppTheme.primaryBlue,
                            ),
                            _buildStatCard(
                              title: 'Habitaciones Libres',
                              value: '$availableRooms',
                              subtitle: '$cleaningRooms en limpieza',
                              icon: Icons.hotel_outlined,
                              color: AppTheme.secondaryTeal,
                            ),
                            _buildStatCard(
                              title: 'Reservas Pendientes',
                              value: '$pendingBookings',
                              subtitle: 'Requieren aprobación',
                              icon: Icons.pending_actions,
                              color: AppTheme.accentGold,
                            ),
                            _buildStatCard(
                              title: 'Ingresos del Mes',
                              value: CurrencyFormatter.formatUsd(monthlyRevenueUsd),
                              subtitle: CurrencyFormatter.formatVes(monthlyRevenueVes),
                              icon: Icons.attach_money,
                              color: AppTheme.successGreen,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Revenue Chart Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ingresos Últimos 6 Meses (USD)',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 18,
                                      ),
                                ),
                                const Icon(Icons.bar_chart, color: AppTheme.primaryBlue),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 220,
                              child: revenueHistory.isEmpty
                                  ? const Center(child: Text('Sin datos históricos aún'))
                                  : BarChart(
                                      BarChartData(
                                        gridData: const FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (val, meta) {
                                                final idx = val.toInt();
                                                if (idx >= 0 && idx < revenueHistory.length) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      revenueHistory[idx]['month']?.toString() ?? '',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: List.generate(revenueHistory.length, (idx) {
                                          final rev = (revenueHistory[idx]['revenueUsd'] as num?)?.toDouble() ?? 0.0;
                                          return BarChartGroupData(
                                            x: idx,
                                            barRods: [
                                              BarChartRodData(
                                                toY: rev > 0 ? rev : 5,
                                                color: AppTheme.primaryBlue,
                                                width: isDesktop ? 28 : 18,
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: color),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
