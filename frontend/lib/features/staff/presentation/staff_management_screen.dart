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
        title: Text(
          'Directorio de Personal & Equipo',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(staffListProvider),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Colaborador', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        onPressed: () => _showUserFormDialog(context, ref),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent)),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No hay colaboradores registrados.'));
          }

          final admins = users.where((u) => u['role'] == 'Admin').length;
          final receptionists = users.where((u) => u['role'] == 'Receptionist').length;
          final housekeeping = users.where((u) => u['role'] == 'Housekeeping').length;
          final guests = users.where((u) => u['role'] == 'Guest').length;

          final crossCount = isDesktop ? (size.width > 1300 ? 3 : 2) : 1;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 26 : 16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Team KPI Summary Strip
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildKpiSummaryCard('TOTAL EQUIPO', '${users.length}', 'Colaboradores activos', Icons.groups, AppTheme.primaryNavy, cardWidth),
                            _buildKpiSummaryCard('ADMINISTRACIÓN', '$admins', 'Gerencia general', Icons.admin_panel_settings, AppTheme.primaryAccent, cardWidth),
                            _buildKpiSummaryCard('RECEPCIÓN', '$receptionists', 'Atención y reservas', Icons.room_service, AppTheme.accentEmerald, cardWidth),
                            _buildKpiSummaryCard('HOUSEKEEPING', '$housekeeping', 'Limpieza y camareras', Icons.cleaning_services, AppTheme.warningOrange, cardWidth),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 26),

                    Text(
                      'Colaboradores & Usuarios Registrados',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 14),

                    // 2. Directory Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 175,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index];
                        return _buildStaffDirectoryCard(context, ref, u);
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

  Widget _buildKpiSummaryCard(String title, String count, String sub, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(count, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                Text(sub, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffDirectoryCard(BuildContext context, WidgetRef ref, Map<String, dynamic> u) {
    final id = u['id']?.toString() ?? '';
    final fullName = u['fullName']?.toString() ?? 'Usuario';
    final username = u['username']?.toString() ?? '';
    final email = u['email']?.toString() ?? '';
    final role = u['role']?.toString() ?? 'Guest';
    final phone = u['phoneNumber']?.toString() ?? '';

    Color roleColor;
    String roleLabel;
    IconData roleIcon;
    if (role == 'Admin') {
      roleColor = AppTheme.primaryNavy;
      roleLabel = 'Administrador General';
      roleIcon = Icons.admin_panel_settings;
    } else if (role == 'Receptionist') {
      roleColor = AppTheme.accentEmerald;
      roleLabel = 'Recepción';
      roleIcon = Icons.room_service;
    } else if (role == 'Housekeeping') {
      roleColor = AppTheme.warningOrange;
      roleLabel = 'Camarera / Limpieza';
      roleIcon = Icons.cleaning_services;
    } else {
      roleColor = AppTheme.primaryAccent;
      roleLabel = 'Huésped';
      roleIcon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cleanCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: roleColor.withAlpha(20),
                radius: 20,
                child: Icon(roleIcon, color: roleColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '@$username',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.email, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textBody),
                ),
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.phone, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textBody, fontWeight: FontWeight.w500),
                ),
              ],
            ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Registrar Colaborador',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17),
          ),
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
                    decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
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
                    decoration: const InputDecoration(labelText: 'Teléfono de Contacto'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Departamento / Rol'),
                    items: const [
                      DropdownMenuItem(value: 'Receptionist', child: Text('Recepción')),
                      DropdownMenuItem(value: 'Housekeeping', child: Text('Limpieza (Camarera)')),
                      DropdownMenuItem(value: 'Admin', child: Text('Administrador')),
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
