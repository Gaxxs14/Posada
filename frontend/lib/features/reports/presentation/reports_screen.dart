import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

final financialReportProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/reports/financial');
  if (response.data['success'] == true) {
    return response.data['data'] as Map<String, dynamic>;
  }
  return {};
});

final occupancyReportProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/reports/occupancy');
  if (response.data['success'] == true) {
    return response.data['data'] as Map<String, dynamic>;
  }
  return {};
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finReportAsync = ref.watch(financialReportProvider);
    final occReportAsync = ref.watch(occupancyReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Auditoría Financiera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(financialReportProvider);
              ref.invalidate(occupancyReportProvider);
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.attach_money), text: 'Ingresos y Pagos'),
                    Tab(icon: Icon(Icons.pie_chart_outline), text: 'Ocupación y Rendimiento'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Financial Tab
                      finReportAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text(err.toString())),
                        data: (data) => _buildFinancialView(data),
                      ),

                      // Occupancy Tab
                      occReportAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text(err.toString())),
                        data: (data) => _buildOccupancyView(data),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialView(Map<String, dynamic> data) {
    final totalUsd = (data['totalRevenueUsd'] as num?)?.toDouble() ?? 0.0;
    final totalVes = (data['totalRevenueVes'] as num?)?.toDouble() ?? 0.0;
    final bookingsCompleted = data['totalBookingsCompleted'] as int? ?? 0;
    final paymentsCount = data['totalPaymentsCount'] as int? ?? 0;
    final List methods = data['revenueByPaymentMethod'] ?? [];
    final List recent = data['recentPayments'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI Summary Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiCard('Total Facturado (USD)', CurrencyFormatter.formatUsd(totalUsd), Icons.monetization_on, AppTheme.successGreen),
              _buildKpiCard('Total Facturado (Bs.)', CurrencyFormatter.formatVes(totalVes), Icons.currency_exchange, AppTheme.secondaryTeal),
              _buildKpiCard('Reservas Completadas', '$bookingsCompleted', Icons.check_circle_outline, AppTheme.primaryBlue),
              _buildKpiCard('Transacciones de Pago', '$paymentsCount', Icons.receipt_long, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue by Payment Method
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingresos por Método de Pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (methods.isEmpty)
                    const Text('No hay registros de pago en este período', style: TextStyle(color: AppTheme.textMuted))
                  else
                    ...methods.map((m) {
                      final method = m['method']?.toString() ?? 'Otros';
                      final total = (m['totalUsd'] as num?)?.toDouble() ?? 0.0;
                      final count = m['transactionsCount'] as int? ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.payment, size: 20, color: AppTheme.primaryBlue),
                            const SizedBox(width: 12),
                            Text(method, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Text('($count transacciones)', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            const Spacer(),
                            Text(CurrencyFormatter.formatUsd(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Payments Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Últimos Pagos Aprobados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    const Text('No hay pagos registrados.', style: TextStyle(color: AppTheme.textMuted))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, idx) {
                        final p = recent[idx];
                        final code = p['bookingCode']?.toString() ?? '';
                        final guest = p['guestName']?.toString() ?? '';
                        final usd = (p['amountUsd'] as num?)?.toDouble() ?? 0.0;
                        final ves = (p['amountVes'] as num?)?.toDouble() ?? 0.0;
                        final method = p['method']?.toString() ?? '';
                        final dateStr = p['createdAt']?.toString() ?? '';
                        final date = DateTime.tryParse(dateStr) ?? DateTime.now();

                        return Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$guest • $code', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Método: $method • ${DateFormat('dd/MM/yyyy HH:mm').format(date)}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(CurrencyFormatter.formatUsd(usd), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                                if (ves > 0) Text(CurrencyFormatter.formatVes(ves), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyView(Map<String, dynamic> data) {
    final avgRate = (data['averageOccupancyRate'] as num?)?.toDouble() ?? 0.0;
    final totalRooms = data['totalRoomsAvailable'] as int? ?? 0;
    final nightsSold = data['totalNightsSold'] as int? ?? 0;
    final List breakdown = data['roomBreakdown'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiCard('Ocupación Promedio', '$avgRate %', Icons.pie_chart, AppTheme.primaryBlue),
              _buildKpiCard('Habitaciones Activas', '$totalRooms', Icons.hotel, AppTheme.secondaryTeal),
              _buildKpiCard('Noches Vendidas', '$nightsSold', Icons.nightlight_round, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rendimiento y Facturación por Habitación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (breakdown.isEmpty)
                    const Text('No hay datos suficientes para el desglose.', style: TextStyle(color: AppTheme.textMuted))
                  else
                    ...breakdown.map((r) {
                      final roomNum = r['roomNumber']?.toString() ?? '';
                      final title = r['roomTitle']?.toString() ?? '';
                      final nights = r['nightsSold'] as int? ?? 0;
                      final revenue = (r['revenueGeneratedUsd'] as num?)?.toDouble() ?? 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.primaryBlue.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                              child: Text(roomNum, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('$nights noches reservadas', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Text(CurrencyFormatter.formatUsd(revenue), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.successGreen)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
