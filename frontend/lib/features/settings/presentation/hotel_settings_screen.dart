import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_theme.dart';

final hotelSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get(ApiEndpoints.settings);
  if (response.data['success'] == true) {
    return response.data['data'] as Map<String, dynamic>;
  }
  throw Exception(response.data['message'] ?? 'Error al cargar configuración');
});

class HotelSettingsScreen extends ConsumerStatefulWidget {
  const HotelSettingsScreen({super.key});

  @override
  ConsumerState<HotelSettingsScreen> createState() => _HotelSettingsScreenState();
}

class _HotelSettingsScreenState extends ConsumerState<HotelSettingsScreen> {
  final _rateController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSaving = false;

  void _updateRate() async {
    final newRate = double.tryParse(_rateController.text);
    if (newRate == null || newRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una tasa válida mayor a 0.'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.patch(
        ApiEndpoints.exchangeRate,
        data: newRate,
      );

      if (response.data['success'] == true) {
        ref.invalidate(hotelSettingsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tasa oficial BCV actualizada en todo el sistema.'), backgroundColor: AppTheme.successGreen),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(hotelSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Hotel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(hotelSettingsProvider),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (settings) {
          final currentRate = (settings['usdExchangeRateBcv'] as num?)?.toDouble() ?? 765.0;
          final hotelName = settings['hotelName']?.toString() ?? '';
          final phone = settings['phone']?.toString() ?? '';
          final address = settings['address']?.toString() ?? '';

          if (_rateController.text.isEmpty) {
            _rateController.text = currentRate.toStringAsFixed(2);
            _nameController.text = hotelName;
            _phoneController.text = phone;
            _addressController.text = address;
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Exchange Rate Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.currency_exchange, color: AppTheme.successGreen),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Tasa de Cambio Oficial (BCV)',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Esta tasa se utiliza para calcular automáticamente todas las cotizaciones y pagos en Bolívares (Bs. VES).',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _rateController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Tasa Bs. / 1 USD',
                                      prefixText: 'Bs. ',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _isSaving ? null : _updateRate,
                                  child: _isSaving
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Text('Actualizar Tasa'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hotel Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información General',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Nombre de la Posada'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp de Atención'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(labelText: 'Dirección o Ubicación'),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Horarios de Atención:\n• Check-In: 14:00 hrs | Check-Out: 11:00 hrs',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
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
}
