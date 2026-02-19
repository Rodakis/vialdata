import 'package:flutter/material.dart'; // <--- ESTA ES LA LÍNEA QUE FALTABA
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos los servicios antes de arrancar la app
  await AuthService.init();
  await NotificationService.init();
  await ConfigService.init();
  
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}