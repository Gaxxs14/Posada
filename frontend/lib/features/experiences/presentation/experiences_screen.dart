import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/presentation/auth_controller.dart';

final experiencesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/experiences');
  if (response.data['success'] == true) {
    final List list = response.data['data'] ?? [];
    return list.map((item) => item as Map<String, dynamic>).toList();
  }
  return [];
});

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final user = ref.watch(authStateProvider).user;
    final isStaff = user?.isStaff ?? false;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tours y Experiencias Turísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(experiencesProvider),
          ),
        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Nuevo Tour'),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              onPressed: () => _showCreateTourDialog(context, ref),
            )
          : null,
      body: experiencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (experiences) {
          if (experiences.isEmpty) {
            return const Center(child: Text('No hay tours activos en este momento'));
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (size.width > 600 ? 2 : 1),
                  childAspectRatio: isDesktop ? 0.85 : 0.95,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  final exp = experiences[index];
                  final id = exp['id']?.toString() ?? '';
                  final title = exp['title']?.toString() ?? '';
                  final desc = exp['description']?.toString() ?? '';
                  final price = (exp['priceUsd'] as num?)?.toDouble() ?? 0.0;
                  final duration = exp['duration']?.toString() ?? '';
                  final category = exp['category']?.toString() ?? 'Tour';
                  final imageUrl = exp['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800';

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(height: 180, color: Colors.grey.shade300),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            if (isStaff)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white.withAlpha(200),
                                  radius: 18,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                                    onPressed: () => _deleteTour(context, ref, id),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 14, color: AppTheme.secondaryTeal),
                                    const SizedBox(width: 4),
                                    Text(duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const Spacer(),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatUsd(price),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(title),
                                            content: Text('Para reservar este tour ($duration - \$${price.toStringAsFixed(2)} USD), puedes solicitarlo directamente en recepción o por WhatsApp.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text('Consultar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteTour(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar tour?'),
        content: const Text('Esta acción eliminará el tour turístico.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final apiClient = ref.read(apiClientProvider);
              await apiClient.dio.delete('/api/experiences/$id');
              ref.invalidate(experiencesProvider);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCreateTourDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '40');
    final durationCtrl = TextEditingController(text: '4 horas');
    final categoryCtrl = TextEditingController(text: 'Tour');
    final imgCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800');
    bool includesTransport = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar Nuevo Tour / Experiencia'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Nombre del Tour')),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio USD', prefixText: '\$ '))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duración (ej. 5 horas)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Categoría (ej. Tour, Gastronomía, Spa)')),
                  const SizedBox(height: 12),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'URL de Imagen')),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Incluye Transporte'),
                    value: includesTransport,
                    onChanged: (val) => setDialogState(() => includesTransport = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final t = titleCtrl.text.trim();
                final d = descCtrl.text.trim();
                final p = double.tryParse(priceCtrl.text) ?? 40.0;
                final dur = durationCtrl.text.trim();
                final cat = categoryCtrl.text.trim();
                final img = imgCtrl.text.trim();

                if (t.isEmpty) return;

                final apiClient = ref.read(apiClientProvider);
                await apiClient.dio.post('/api/experiences', data: {
                  'title': t,
                  'description': d,
                  'priceUsd': p,
                  'duration': dur,
                  'category': cat,
                  'imageUrl': img,
                  'includesTransport': includesTransport,
                });

                if (context.mounted) Navigator.pop(dialogCtx);
                ref.invalidate(experiencesProvider);
              },
              child: const Text('Crear Tour'),
            ),
          ],
        ),
      ),
    );
  }
}
