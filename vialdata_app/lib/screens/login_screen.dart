import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _formVisible = false;

  void _login() async {
    setState(() => _isLoading = true);

    // Simulamos un pequeño delay para efecto visual
    await Future.delayed(const Duration(milliseconds: 500));

    bool success = await AuthService.login(
        _userController.text.trim(), _passController.text.trim());

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Credenciales incorrectas'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => setState(() => _formVisible = true));
  }

  void _showHelpSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          'Las cuentas las administra el equipo interno. Escribinos para actualizar tu clave.'),
      backgroundColor: Colors.black87,
      duration: Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          Positioned.fill(child: _buildGrid()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    height: 110,
                  ),
                  const SizedBox(height: 16),
                  Text('VIALDATA CAMPO', style: AppStyles.heroDisplay),
                  const SizedBox(height: 10),
                  Text(
                    'Monitorea remitos e informes en tiempo real, desde el campo hasta la oficina central. Los recordatorios te mantienen sincronizado.',
                    textAlign: TextAlign.center,
                    style: AppStyles.heroSubtitle,
                  ),
                  const SizedBox(height: 32),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 500),
                    offset: _formVisible ? Offset.zero : const Offset(0, 0.15),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _formVisible ? 1 : 0,
                      child: Container(
                        width: double.infinity,
                        decoration: AppStyles.glassPanel(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on,
                                    color: AppColors.neonAccent),
                                const SizedBox(width: 8),
                                Text('Acceso seguro', style: AppStyles.label),
                                const Spacer(),
                                Chip(
                                  backgroundColor: AppColors.reminderAccent,
                                  label: Text('Recordatorio 16:30',
                                      style: AppStyles.chipLabel),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _userController,
                              decoration: AppStyles.inputDecoration(
                                  label: 'Usuario',
                                  prefixIcon: Icons.person,
                                  fillColor: AppColors.surfaceCard),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passController,
                              obscureText: true,
                              decoration: AppStyles.inputDecoration(
                                  label: 'Contraseña',
                                  prefixIcon: Icons.lock,
                                  fillColor: AppColors.surfaceCard),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('INGRESAR',
                                        style: TextStyle(
                                            letterSpacing: 1.8,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.help_outline,
                                    color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                TextButton(
                                  onPressed: _showHelpSnackBar,
                                  child: Text('Necesito ayuda',
                                      style: AppStyles.label),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tus datos quedan guardados localmente y se sincronizan cuando hay conexión. Instala la app en tablets y móviles del campo y no pierdas información.',
                              textAlign: TextAlign.center,
                              style: AppStyles.bodyText,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statPill('Última sincronía', '07:12'),
                      const SizedBox(width: 12),
                      _statPill('Modo nocturno', 'Activo'),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.heroCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(value, style: AppStyles.heroDisplay.copyWith(fontSize: 16)),
          Text(label, style: AppStyles.label.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridLine.withOpacity(0.18)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
    for (double x = 0; x < size.width + size.height; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
    final circlePaint = Paint()
      ..color = AppColors.neonAccent.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.15), 70, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.08), 90, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
