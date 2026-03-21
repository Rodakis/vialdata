import 'package:flutter/material.dart'; // <--- ESTA ES LA LÍNEA QUE FALTABA
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos los servicios antes de arrancar la app
  await AuthService.init();
  await NotificationService.init();

  // Programamos la alarma diaria (versión inexacta para API 34)
  await NotificationService.scheduleDailyReportReminder();

  runApp(const VialDataApp());
}

class VialDataApp extends StatelessWidget {
  const VialDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VialData',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.heroGradientStart,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.beigePastelLight,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: AppColors.surfaceCard,
        ),
    ),
      home: const LoginScreen(),
    );
  }
}
