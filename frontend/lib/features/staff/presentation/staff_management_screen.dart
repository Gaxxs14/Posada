import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';

final staffListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get('/api/users');
  if (response.data['success'] == true) {
    final List list = response.data['data'] ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
  return [];
});

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: AppBar(
        title: Text('Directorio de Personal & Usuarios', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(staffListProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nuevo Colaborador', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        onPressed: () => _showUserFormDialog(context, ref),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No hay colaboradores registrados.'));
          }

          final crossCount = isDesktop ? 2 : 1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 28 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(22),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.navyHeroGradient,
                        borderRadius: BorderRadius.circular(20),
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
                            child: const Icon(Icons.badge_rounded, color: Color(0xFF061325), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Equipo del Resort & Huéspedes', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Gestión de accesos, roles de recepción y camareras', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid of users
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 140,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index];
                        return _buildUserCard(context, ref, u);
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

  Widget _buildUserCard(BuildContext context, WidgetRef ref, Map<String, dynamic> u) {
    final id = u['id']?.toString() ?? '';
    final fullName = u['fullName']?.toString() ?? 'Usuario';
    final username = u['username']?.toString() ?? '';
    final email = u['email']?.toString() ?? '';
    final role = u['role']?.toString() ?? 'Guest';
    final phone = u['phoneNumber']?.toString() ?? '';

    Color roleColor;
    String roleLabel;
    if (role == 'Admin') {
      roleColor = AppTheme.accentGold;
      roleLabel = 'Administrador General';
    } else if (role == 'Receptionist') {
      roleColor = AppTheme.caribbeanTeal;
      roleLabel = 'Recepción';
    } else if (role == 'Housekeeping') {
      roleColor = AppTheme.warningOrange;
      roleLabel = 'Camarera / Limpieza';
    } else {
      roleColor = AppTheme.infoBlue;
      roleLabel = 'Huésped VIP';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.luxuryCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: role == 'Admin' ? AppTheme.goldGradient : null,
              color: role != 'Admin' ? roleColor.withAlpha(20) : null,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: role == 'Admin' ? const Color(0xFF061325) : roleColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: roleColor.withAlpha(80)),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('@$username • $email', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Tlf: $phone', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserFormDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final userController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passController = TextEditingController(text: 'Staff123*');
    String role = 'Receptionist';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('Nuevo Colaborador', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre y Apellido'),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userController,
                    decoration: const InputDecoration(labelText: 'Nombre de Usuario (login)'),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                    validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Rol en la Posada'),
                    items: const [
                      DropdownMenuItem(value: 'Receptionist', child: Text('Recepción & Reservas')),
                      DropdownMenuItem(value: 'Housekeeping', child: Text('Limpieza (Housekeeping)')),
                      DropdownMenuItem(value: 'Admin', child: Text('Administrador General')),
                    ],
                    onChanged: (val) => setState(() => role = val!),
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
                    await apiClient.dio.post('/api/users', data: {
                      'fullName': nameController.text.trim(),
                      'username': userController.text.trim(),
                      'email': emailController.text.trim(),
                      'phoneNumber': phoneController.text.trim(),
                      'password': passController.text.trim(),
                      'role': role,
                    });
                    ref.invalidate(staffListProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Colaborador creado exitosamente'), backgroundColor: AppTheme.successGreen),
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
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
