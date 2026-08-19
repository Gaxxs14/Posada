import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'available':
      case 'disponible':
        bg = AppTheme.successGreen.withAlpha(30);
        fg = AppTheme.successGreen;
        label = 'Disponible';
        icon = Icons.check_circle_outline;
        break;
      case 'occupied':
      case 'ocupada':
        bg = AppTheme.primaryBlue.withAlpha(30);
        fg = AppTheme.primaryBlue;
        label = 'Ocupada';
        icon = Icons.hotel;
        break;
      case 'needscleaning':
      case 'en limpieza':
      case 'limpieza':
        bg = AppTheme.warningOrange.withAlpha(30);
        fg = AppTheme.warningOrange;
        label = 'Limpieza';
        icon = Icons.cleaning_services_outlined;
        break;
      case 'undermaintenance':
      case 'mantenimiento':
        bg = AppTheme.errorRed.withAlpha(30);
        fg = AppTheme.errorRed;
        label = 'Mantenimiento';
        icon = Icons.build_outlined;
        break;
      case 'confirmed':
      case 'aprobado':
      case 'confirmada':
        bg = AppTheme.successGreen.withAlpha(30);
        fg = AppTheme.successGreen;
        label = 'Confirmada';
        icon = Icons.verified_outlined;
        break;
      case 'pending':
      case 'pendiente':
        bg = AppTheme.warningOrange.withAlpha(30);
        fg = AppTheme.warningOrange;
        label = 'Pendiente';
        icon = Icons.schedule;
        break;
      case 'checkedin':
        bg = AppTheme.secondaryTeal.withAlpha(30);
        fg = AppTheme.secondaryTeal;
        label = 'En Estadía';
        icon = Icons.login;
        break;
      case 'checkedout':
        bg = Colors.blueGrey.withAlpha(30);
        fg = Colors.blueGrey;
        label = 'Finalizada';
        icon = Icons.logout;
        break;
      case 'cancelled':
      case 'cancelada':
        bg = AppTheme.errorRed.withAlpha(30);
        fg = AppTheme.errorRed;
        label = 'Cancelada';
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = Colors.grey.withAlpha(30);
        fg = Colors.grey;
        label = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
