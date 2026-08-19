import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

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
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(hotelSettingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: Text('Configuración General del Resort', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(hotelSettingsProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (settings) {
          final currentBcv = (settings['usdExchangeRateBcv'] as num?)?.toDouble() ?? 765.0;
          final hotelName = settings['hotelName']?.toString() ?? 'Posada Turística Sol y Mar';
          final phone = settings['phone']?.toString() ?? '+58 424-8170076';
          final address = settings['address']?.toString() ?? 'Sector Playa Grande, Venezuela';
          final email = settings['email']?.toString() ?? 'contacto@posadasolmar.com';

          if (_rateController.text.isEmpty) {
            _rateController.text = currentBcv.toStringAsFixed(2);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Official BCV Rate Card (Golden Hero)
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        gradient: AppTheme.navyHeroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.luxuryCardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: AppTheme.goldGlowShadow,
                                ),
                                child: const Icon(Icons.currency_exchange_rounded, color: Color(0xFF061325), size: 22),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tasa Oficial de Cambio (BCV)',
                                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Afecta automáticamente cotizaciones, reportes y precios en Bolívares (Bs.)',
                                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: TextField(
                                    controller: _rateController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    decoration: const InputDecoration(
                                      labelText: 'Tasa BCV (Bs. por 1 USD)',
                                      suffixText: 'Bs.',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentGold,
                                  foregroundColor: const Color(0xFF061325),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _isSaving ? null : _updateRate,
                                child: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF061325)))
                                    : const Text('Actualizar Tasa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Valor actual activo en sistema: ${CurrencyFormatter.formatVes(currentBcv)} Bs. por cada \$1 USD',
                            style: const TextStyle(color: AppTheme.accentGoldLight, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 2. Hotel Identity Card
                    Container(
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
                          Text('Información de la Posada', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Datos fiscales y de contacto mostrados en cotizaciones y comprobantes', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          const SizedBox(height: 20),

                          _buildInfoTile('Nombre del Establecimiento', hotelName, Icons.hotel),
                          const Divider(height: 20),
                          _buildInfoTile('Dirección Física', address, Icons.location_on_outlined),
                          const Divider(height: 20),
                          _buildInfoTile('Teléfono de Contacto / WhatsApp', phone, Icons.phone_outlined),
                          const Divider(height: 20),
                          _buildInfoTile('Correo Electrónico', email, Icons.email_outlined),
                          const Divider(height: 20),
                          _buildInfoTile('Horarios de Atención', 'Check-In: 15:00 • Check-Out: 12:00', Icons.access_time_outlined),
                        ],
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

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.bgCanvas,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryNavy),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}
