import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PosadaApp()));
}

class PosadaApp extends ConsumerWidget {
  const PosadaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.isInitialLoading) {
      return MaterialApp(
        title: 'Posada - Sistema Hotelero',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hotel, size: 64, color: AppTheme.primaryBlue),
                SizedBox(height: 16),
                CircularProgressIndicator(color: AppTheme.primaryBlue),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Posada - Sistema Hotelero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.user != null
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}
