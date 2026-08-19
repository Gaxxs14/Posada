import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Personal y Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(staffListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Personal'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showUserFormDialog(context, ref),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final id = user['id']?.toString() ?? '';
                  final fullName = user['fullName']?.toString() ?? '';
                  final username = user['username']?.toString() ?? '';
                  final email = user['email']?.toString() ?? '';
                  final phone = user['phoneNumber']?.toString() ?? '';
                  final role = user['role']?.toString() ?? 'Guest';
                  final isActive = user['isActive'] as bool? ?? true;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(role).withAlpha(30),
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _getRoleColor(role)),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 8),
                          _buildRoleBadge(role),
                          if (!isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                              child: const Text('Inactivo', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text('@$username • $email • $phone', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(isActive ? Icons.block : Icons.check_circle_outline, color: isActive ? Colors.orange : AppTheme.successGreen),
                            tooltip: isActive ? 'Desactivar' : 'Activar',
                            onPressed: () async {
                              final apiClient = ref.read(apiClientProvider);
                              await apiClient.dio.patch('/api/users/$id/status');
                              ref.invalidate(staffListProvider);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                            tooltip: 'Editar',
                            onPressed: () => _showUserFormDialog(context, ref, user: user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                            tooltip: 'Eliminar',
                            onPressed: () => _deleteUser(context, ref, id),
                          ),
                        ],
                      ),
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.purple;
      case 'Receptionist':
        return AppTheme.primaryBlue;
      case 'Housekeeping':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildRoleBadge(String role) {
    String label;
    switch (role) {
      case 'Admin':
        label = 'Administrador';
        break;
      case 'Receptionist':
        label = 'Recepcionista';
        break;
      case 'Housekeeping':
        label = 'Personal Limpieza';
        break;
      default:
        label = 'Huésped';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: _getRoleColor(role).withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: _getRoleColor(role), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _deleteUser(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: const Text('Esta acción eliminará al usuario o lo desactivará si tiene reservas registradas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final apiClient = ref.read(apiClientProvider);
              await apiClient.dio.delete('/api/users/$id');
              ref.invalidate(staffListProvider);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showUserFormDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? user}) {
    final isEditing = user != null;
    final fullNameCtrl = TextEditingController(text: user?['fullName']?.toString() ?? '');
    final usernameCtrl = TextEditingController(text: user?['username']?.toString() ?? '');
    final emailCtrl = TextEditingController(text: user?['email']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: user?['phoneNumber']?.toString() ?? '');
    final passwordCtrl = TextEditingController();

    String selectedRole = user?['role']?.toString() ?? 'Receptionist';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Personal / Usuario' : 'Registrar Nuevo Personal'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre y Apellido'),
                  ),
                  const SizedBox(height: 12),
                  if (!isEditing) ...[
                    TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Teléfono / Móvil'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Rol Asignado'),
                    items: const [
                      DropdownMenuItem(value: 'Admin', child: Text('Administrador (Acceso Total)')),
                      DropdownMenuItem(value: 'Receptionist', child: Text('Recepcionista (Front Desk)')),
                      DropdownMenuItem(value: 'Housekeeping', child: Text('Personal de Limpieza')),
                      DropdownMenuItem(value: 'Guest', child: Text('Huésped')),
                    ],
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isEditing ? 'Nueva Contraseña (Opcional)' : 'Contraseña Inicial',
                      hintText: isEditing ? 'Dejar en blanco para conservar actual' : 'Mínimo 6 caracteres',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final name = fullNameCtrl.text.trim();
                final username = usernameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final pass = passwordCtrl.text;

                if (name.isEmpty || email.isEmpty) return;

                final apiClient = ref.read(apiClientProvider);

                if (isEditing) {
                  await apiClient.dio.put('/api/users/${user['id']}', data: {
                    'fullName': name,
                    'email': email,
                    'phoneNumber': phone,
                    'role': selectedRole,
                    if (pass.isNotEmpty) 'newPassword': pass,
                  });
                } else {
                  if (username.isEmpty || pass.isEmpty) return;
                  await apiClient.dio.post('/api/users', data: {
                    'fullName': name,
                    'username': username,
                    'email': email,
                    'phoneNumber': phone,
                    'password': pass,
                    'role': selectedRole,
                  });
                }

                if (context.mounted) Navigator.pop(dialogCtx);
                ref.invalidate(staffListProvider);
              },
              child: Text(isEditing ? 'Guardar Cambios' : 'Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
