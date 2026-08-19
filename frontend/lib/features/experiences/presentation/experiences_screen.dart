import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/presentation/auth_controller.dart';

final experiencesListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/experiences');
  if (response.data['success'] == true) {
    final List list = response.data['data'] ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
  return [];
});

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(experiencesListProvider);
    final user = ref.watch(authStateProvider).user;
    final isAdmin = user?.role == 'Admin';
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: Text('Tours & Experiencias Caribeñas', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar Tours',
            onPressed: () => ref.invalidate(experiencesListProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva Experiencia', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              onPressed: () => _showAddExperienceDialog(context, ref),
            )
          : null,
      body: experiencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (experiences) {
          if (experiences.isEmpty) {
            return const Center(child: Text('No hay tours ni experiencias disponibles en este momento.'));
          }

          final crossCount = isDesktop ? (size.width > 1300 ? 3 : 2) : 1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 28 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1350),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Hero Banner
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.navyHeroGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppTheme.luxuryCardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.sailing_rounded, color: Color(0xFF061325), size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paseos Náuticos, Gastronomía & Spa',
                                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Actividades exclusivas para complementar la estadía de nuestros huéspedes',
                                  style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid of experiences
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 440,
                      ),
                      itemCount: experiences.length,
                      itemBuilder: (context, index) {
                        final exp = experiences[index];
                        return _buildExperienceCard(context, ref, exp, isAdmin);
                      },
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

  Widget _buildExperienceCard(BuildContext context, WidgetRef ref, Map<String, dynamic> exp, bool isAdmin) {
    final id = exp['id']?.toString() ?? '';
    final title = exp['title']?.toString() ?? '';
    final description = exp['description']?.toString() ?? '';
    final priceUsd = (exp['priceUsd'] as num?)?.toDouble() ?? 0.0;
    final priceVes = priceUsd * 765.0;
    final duration = exp['duration']?.toString() ?? 'Consultar';
    final category = exp['category']?.toString() ?? 'Paseo';
    final imageUrl = exp['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800';
    final includesTransport = exp['includesTransport'] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Photo with Category and Price Overlay
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100),
                errorWidget: (context, url, error) => Container(
                  height: 190,
                  color: AppTheme.primaryNavy,
                  child: const Center(child: Icon(Icons.sailing, size: 48, color: Colors.white24)),
                ),
              ),
              // Category Chip
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061325).withAlpha(200),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(color: AppTheme.accentGoldLight, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              // Price Tag
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.formatUsd(priceUsd),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${CurrencyFormatter.formatVes(priceVes)} Bs.',
                        style: TextStyle(color: AppTheme.accentGoldLight.withAlpha(220), fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Content Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Duration & Transport pills
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCanvas,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(duration, style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (includesTransport)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.caribbeanTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_bus_outlined, size: 13, color: AppTheme.caribbeanTeal),
                            SizedBox(width: 4),
                            Text('Traslado Inc.', style: TextStyle(fontSize: 11, color: AppTheme.caribbeanTeal, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Booking / Delete Button
                if (isAdmin)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 16),
                      label: const Text('Eliminar Experiencia', style: TextStyle(color: AppTheme.errorRed, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _deleteExperience(context, ref, id),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                      label: const Text('Reservar Experiencia'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Experiencia "$title" solicitada al Concierge.'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteExperience(BuildContext context, WidgetRef ref, String id) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.dio.delete('/api/experiences/$id');
      ref.invalidate(experiencesListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experiencia eliminada.'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _showAddExperienceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: '4 horas');
    String category = 'Paseo Náutico';
    bool includesTransport = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('Nueva Experiencia', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título del Tour / Actividad'),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Descripción del Paseo'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio por Persona (\$ USD)', prefixText: '\$ '),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Duración Estimada'),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Incluye Traslado / Lancha', style: TextStyle(fontSize: 13)),
                    value: includesTransport,
                    onChanged: (val) => setState(() => includesTransport = val ?? true),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final apiClient = ref.read(apiClientProvider);
                    await apiClient.dio.post('/api/experiences', data: {
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'priceUsd': double.parse(priceController.text.trim()),
                      'duration': durationController.text.trim(),
                      'category': category,
                      'imageUrl': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
                      'includesTransport': includesTransport,
                    });
                    ref.invalidate(experiencesListProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Experiencia publicada con éxito'), backgroundColor: AppTheme.successGreen),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
                      );
                    }
                  }
                }
              },
              child: const Text('Publicar Tour'),
            ),
          ],
        ),
      ),
    );
  }
}
